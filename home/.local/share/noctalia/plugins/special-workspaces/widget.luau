--!nonstrict
-- Shows Hyprland special workspaces, which the built-in workspaces widget hides.
-- State comes from Hyprland's event socket; polling takes over while the socket is unavailable
-- and the stream is retried with backoff.

local STREAM_CLOSED = "__special_workspaces_stream_closed__"
local RESYNC_MS = 5000
local RETRY_MIN_MS = 1000
local RETRY_MAX_MS = 30000

local SNAPSHOT_CMD = [[printf '{"monitors":%s,"workspaces":%s}' "$(hyprctl -j monitors)" "$(hyprctl -j workspaces)"]]

-- Events that can change which special workspaces exist, their window count, or which one is open.
local REFRESH_EVENTS = {
  activespecial = true,
  activespecialv2 = true,
  createworkspace = true,
  createworkspacev2 = true,
  destroyworkspace = true,
  destroyworkspacev2 = true,
  moveworkspace = true,
  moveworkspacev2 = true,
  renameworkspace = true,
  openwindow = true,
  closewindow = true,
  movewindow = true,
  movewindowv2 = true,
  focusedmon = true,
  focusedmonv2 = true,
  monitoradded = true,
  monitoraddedv2 = true,
  monitorremoved = true,
  monitorremovedv2 = true,
}

local mode = "stream"
local retryAt = nil
local retryDelay = RETRY_MIN_MS
local refreshing = false
local dirty = false
local lastSignature = nil

-- Short name ("magic") -> window count, for every special workspace Hyprland reports.
local windowsByName = {}
-- Monitor connector -> short name of the special workspace open on it.
local openByMonitor = {}

local function shellQuote(value)
  return "'" .. (string.gsub(value, "'", "'\\''")) .. "'"
end

local function specialShortName(name)
  if type(name) ~= "string" then
    return nil
  end
  if name == "special" then
    return "special"
  end
  if string.sub(name, 1, 8) == "special:" then
    return string.sub(name, 9)
  end
  return nil
end

local function tr(key)
  return noctalia.tr(key)
end

local function glyphFor(name)
  local glyphs = noctalia.getConfig("glyphs") or {}
  return glyphs[name] or noctalia.getConfig("default_glyph") or "app-window"
end

local function visibleWorkspaces()
  local seen = {}
  local result = {}
  local function add(name)
    if name ~= nil and not seen[name] then
      seen[name] = true
      table.insert(result, name)
    end
  end

  for _, name in ipairs(noctalia.getConfig("always_show") or {}) do
    add(name)
  end

  local discovered = {}
  for name in pairs(windowsByName) do
    table.insert(discovered, name)
  end
  for _, name in pairs(openByMonitor) do
    table.insert(discovered, name)
  end
  table.sort(discovered)
  for _, name in ipairs(discovered) do
    add(name)
  end
  return result
end

local function isOpenHere(name, output)
  if output == nil then
    for _, open in pairs(openByMonitor) do
      if open == name then
        return true
      end
    end
    return false
  end
  return openByMonitor[output] == name
end

-- Geometry of the built-in workspaces widget (Style::baseGlyphSize, spaceXs, fontSizeMini).
local PILL_BASE = 16
local PILL_GAP = 4
local PILL_FONT_SIZE = 11

-- Same pairing as WorkspacesWidget::onRoleForFill; anything else gets on_surface.
local ON_ROLE = {
  primary = "on_primary",
  secondary = "on_secondary",
  tertiary = "on_tertiary",
  error = "on_error",
  primary_container = "on_primary_container",
  secondary_container = "on_secondary_container",
  tertiary_container = "on_tertiary_container",
  error_container = "on_error_container",
}

-- Pill colors and sizes come from [widget.workspaces], so both widgets look alike.
local function pillStyle()
  local native = noctalia.getSetting("widget.workspaces")
  if type(native) ~= "table" then
    native = {}
  end
  local scale = tonumber(native.pill_scale) or 1
  return {
    height = math.floor(PILL_BASE * scale + 0.5),
    activeSize = tonumber(native.active_pill_size) or 2.2,
    inactiveSize = tonumber(native.inactive_pill_size) or 1,
    focused = native.focused_color or "primary",
    occupied = native.occupied_color or "secondary",
    empty = native.empty_color or "secondary",
    radius = tonumber(native.capsule_radius),
  }
end

local function pillChip(name, windows, open, showGlyph, showName, style)
  local fill = open and style.focused or (windows > 0 and style.occupied or style.empty)
  local textColor = ON_ROLE[fill] or "on_surface"
  local height = style.height
  local halfHeight = height / 2
  local radius = style.radius ~= nil and math.clamp(style.radius, 0, halfHeight) or halfHeight

  local children = {}
  if showGlyph then
    table.insert(children, ui.glyph({ name = glyphFor(name), size = PILL_FONT_SIZE, color = textColor }))
  end
  if showName then
    table.insert(children, ui.label({ text = name, fontSize = PILL_FONT_SIZE, color = textColor }))
  end

  return {
    fill = fill,
    radius = radius,
    minHeight = height,
    minWidth = math.floor(height * (open and style.activeSize or style.inactiveSize) + 0.5),
    -- The built-in pill pads its label by 0.6 x its height in total.
    paddingH = math.floor(height * 0.3 + 0.5),
    justify = "center",
  }, children
end

local refresh

-- With a Lua config, `hyprctl dispatch` evaluates its argument as `hl.dispatch(<arg>)`;
-- legacy configs take the classic dispatcher syntax instead.
local function toggle(name)
  local luaArgs = name == "special" and "" or string.format("%q", name)
  local luaDispatch = "hl.dsp.workspace.toggle_special(" .. luaArgs .. ")"
  noctalia.runAsync({ "hyprctl", "dispatch", luaDispatch }, function(result)
    if result.exitCode ~= 0 or string.match(result.stdout, "^ok") == nil then
      local legacyArgument = name == "special" and "" or name
      noctalia.runAsync({ "hyprctl", "dispatch", "togglespecialworkspace", legacyArgument }, function()
        refresh()
      end)
      return
    end
    refresh()
  end)
end

local function render()
  local output = barWidget.outputName()
  local names = visibleWorkspaces()

  local display = noctalia.getConfig("display") or "glyph"
  local usePills = noctalia.getConfig("style") == "pills"
  local style = usePills and pillStyle() or nil
  local parts = { output or "", display, style and noctalia.json.encode(style) or "plain" }
  for _, name in ipairs(names) do
    table.insert(parts, name .. "=" .. tostring(windowsByName[name] or 0) .. ":" .. tostring(isOpenHere(name, output)))
  end
  local signature = table.concat(parts, "|")
  if signature == lastSignature then
    return
  end
  lastSignature = signature

  if #names == 0 then
    barWidget.setVisible(false)
    return
  end
  barWidget.setVisible(true)

  local showGlyph = display ~= "name"
  local showName = display ~= "glyph"
  local chips = {}
  for _, name in ipairs(names) do
    local windows = windowsByName[name] or 0
    local open = isOpenHere(name, output)
    local props, children
    if usePills then
      props, children = pillChip(name, windows, open, showGlyph, showName, style)
    else
      local color = open and "primary" or (windows > 0 and "on_surface" or "on_surface_variant")
      children = {}
      if showGlyph then
        table.insert(children, ui.glyph({ name = glyphFor(name), color = color }))
      end
      if showName then
        table.insert(children, ui.label({ text = name, color = color }))
      end
      props = { paddingH = 2 }
    end

    local status = (open and tr("tooltip.open") or tr("tooltip.closed")) .. ", " .. windows .. " " .. tr("tooltip.windows")
    props.key = "ws-" .. name
    props.gap = 4
    props.align = "center"
    props.tooltip = name .. ": " .. status
    props.onClick = function()
      toggle(name)
    end
    table.insert(chips, ui.row(props, children))
  end

  local container = barWidget.isVertical() and ui.column or ui.row
  barWidget.render(container({ gap = usePills and PILL_GAP or 6, align = "center" }, chips))
end

local function applySnapshot(raw)
  local snapshot = noctalia.json.decode(raw)
  if type(snapshot) ~= "table" or type(snapshot.monitors) ~= "table" or type(snapshot.workspaces) ~= "table" then
    return
  end

  local windows = {}
  for _, workspace in ipairs(snapshot.workspaces) do
    local name = specialShortName(workspace.name)
    if name ~= nil then
      windows[name] = tonumber(workspace.windows) or 0
    end
  end

  -- Legacy IPC reports a closed special as { id = 0, name = "" }; the typed schema omits it.
  local open = {}
  for _, monitor in ipairs(snapshot.monitors) do
    local special = monitor.specialWorkspace
    local name = type(special) == "table" and specialShortName(special.name) or nil
    if name ~= nil and type(monitor.name) == "string" then
      open[monitor.name] = name
    end
  end

  windowsByName = windows
  openByMonitor = open
  render()
end

refresh = function()
  if refreshing then
    dirty = true
    return
  end
  refreshing = true
  local started = noctalia.runAsync(SNAPSHOT_CMD, function(result)
    refreshing = false
    if result.exitCode == 0 then
      applySnapshot(result.stdout)
    end
    if dirty then
      dirty = false
      refresh()
    end
  end)
  if not started then
    refreshing = false
  end
end

local function enterPolling()
  mode = "poll"
  retryAt = noctalia.nowMs() + retryDelay
  retryDelay = math.min(retryDelay * 2, RETRY_MAX_MS)
  noctalia.setUpdateInterval(noctalia.getConfig("poll_interval_ms") or 150)
end

local function onStreamLine(line)
  if line == STREAM_CLOSED then
    noctalia.log("special-workspaces: event socket closed, falling back to polling")
    enterPolling()
    refresh()
    return
  end
  retryDelay = RETRY_MIN_MS
  local event = string.match(line, "^([%w_]+)>>")
  if event ~= nil and REFRESH_EVENTS[event] then
    refresh()
  end
end

local function startStream()
  local signature = noctalia.getenv("HYPRLAND_INSTANCE_SIGNATURE")
  local runtimeDir = noctalia.getenv("XDG_RUNTIME_DIR")
  if signature == nil or runtimeDir == nil or not noctalia.commandExists("socat") then
    return false
  end
  local socketPath = runtimeDir .. "/hypr/" .. signature .. "/.socket2.sock"
  if not noctalia.fileExists(socketPath) then
    return false
  end
  -- runStream has no exit callback, so the sentinel line reports that socat ended.
  local command = "socat -U - UNIX-CONNECT:" .. shellQuote(socketPath) .. " 2>/dev/null; echo " .. STREAM_CLOSED
  return noctalia.runStream(command, onStreamLine)
end

local function connect()
  if startStream() then
    mode = "stream"
    retryAt = nil
    noctalia.setUpdateInterval(RESYNC_MS)
  else
    enterPolling()
  end
  refresh()
end

function update()
  if mode == "poll" and retryAt ~= nil and noctalia.nowMs() >= retryAt then
    connect()
    return
  end
  -- Polling in poll mode, a periodic resync in stream mode.
  refresh()
end

connect()
