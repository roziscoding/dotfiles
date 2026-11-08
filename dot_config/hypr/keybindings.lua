require("globals")
require("notification")
---------------------
---- KEYBINDINGS ----
---------------------


hl.bind(MAIN_MOD .. " + Return", hl.dsp.exec_cmd(TERMINAL))
hl.bind(MAIN_MOD .. " + C", hl.dsp.window.close())
hl.bind(MAIN_MOD .. " + Q", hl.dsp.window.signal({ signal = 15 })) -- SIGTERM
hl.bind(MAIN_MOD .. " + SHIFT + Q", hl.dsp.window.kill())
hl.bind(MAIN_MOD .. " + SHIFT + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown"))
hl.bind(MAIN_MOD .. " + E", hl.dsp.exec_cmd(FILE_MANAGER))
hl.bind(MAIN_MOD .. " + F", function()
	local win = hl.get_active_window()
	if not win then
		return
	end
	if win.floating then
		hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "unset" }))
		hl.dispatch(hl.dsp.window.float({ action = "disable" }))
	else
		hl.dispatch(hl.dsp.window.float({ action = "enable" }))
		hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "set" }))
	end
end)
hl.bind(MAIN_MOD .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(MAIN_MOD .. " + Space", hl.dsp.exec_cmd(LAUNCHER_COMMAND))
hl.bind(MAIN_MOD .. " + P", hl.dsp.window.pseudo())
hl.bind(MAIN_MOD .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with MAIN_MOD + arrow keys
hl.bind(MAIN_MOD .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(MAIN_MOD .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(MAIN_MOD .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(MAIN_MOD .. " + down", hl.dsp.focus({ direction = "down" }))

-- Move windows with MAIN_MOD + arrow keys
hl.bind(MAIN_MOD .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(MAIN_MOD .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(MAIN_MOD .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(MAIN_MOD .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces with MAIN_MOD + [0-9]
-- Move active window to a workspace with MAIN_MOD + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(MAIN_MOD .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(MAIN_MOD .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Go to fixed workspaces
hl.bind(MAIN_MOD .. " + m", hl.dsp.focus({ workspace = "10" }))
hl.bind(MAIN_MOD .. " + b", hl.dsp.focus({ workspace = "9" }))


-- Move/resize windows with MAIN_MOD + LMB/RMB and dragging
hl.bind(MAIN_MOD .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(MAIN_MOD .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Lock screen
hl.bind(MAIN_MOD .. " + L", hl.dsp.exec_cmd("noctalia msg session lock"))

-----------------------------
---- SCREENSHOT BINDINGS ----
-----------------------------
local function screenshot(modes)
	local m = ""
	for _, mode in ipairs(modes) do
		m = m .. "-m " .. mode .. " "
	end
	return hl.dsp.exec_cmd(
		"hyprshot "
			.. m
			.. "--raw --freeze | satty --filename - --actions-on-enter save-to-clipboard --actions-on-enter exit --copy-command wl-copy"
	)
end

-- Selection
hl.bind(MAIN_MOD .. " + SHIFT + CONTROL + 4", screenshot({ "region" }))
-- Window
hl.bind(MAIN_MOD .. " + SHIFT + CONTROL + 3", screenshot({ "window" }))
-- Screen
hl.bind(MAIN_MOD .. " + SHIFT + CONTROL + 2", screenshot({ "output", "active" }))

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Recent VSCode projects with vicinae
hl.bind(
	MAIN_MOD .. "+ SHIFT + C",
	hl.dsp.exec_cmd("vicinae vicinae://launch/@ShyAssassin/store.vicinae.vscode-recents/open-recents")
)

-- Clipboard history with vicinae
hl.bind(MAIN_MOD .. "+ SHIFT + V", hl.dsp.exec_cmd("vicinae vicinae://launch/clipboard/history"))

-- Wraps a value in single quotes for safe interpolation into a shell command
local function sh_quote(value)
	return "'" .. (tostring(value):gsub("'", "'\\''")) .. "'"
end

-- Rename current workspace
hl.bind(MAIN_MOD .. "+ SHIFT + F2", function()
	local workspace = hl.get_active_workspace()
	if not workspace then
		Notification.error("No active workspace")
		return
	end

	-- yad opens pre-filled with the current name minus its "$WORKSPACE_ID: " prefix, so renaming
	-- an already-named workspace edits the name instead of stacking prefixes. Cancelling keeps
	-- the current name; confirming an empty entry falls back to the bare id.
	local yad_command = 'yad --no-buttons --borders 20 --entry --entry-text="$PREFILL"'
	local vars = "WORKSPACE_ID="
		.. sh_quote(workspace.id)
		.. "; "
		.. "CURRENT_NAME="
		.. sh_quote(workspace.name)
		.. "; "
		.. 'case "$CURRENT_NAME" in '
		.. "\"$WORKSPACE_ID\") PREFILL='';; "
		.. '"$WORKSPACE_ID: "*) PREFILL=${CURRENT_NAME#$WORKSPACE_ID: };; '
		.. "*) PREFILL=$CURRENT_NAME;; esac; "
		.. "if NEW_NAME=`"
		.. yad_command
		.. "`; then "
		.. 'if [ -n "$NEW_NAME" ]; then FINAL_NAME="$WORKSPACE_ID: $NEW_NAME"; else FINAL_NAME="$WORKSPACE_ID"; fi; '
		.. "else FINAL_NAME=$CURRENT_NAME; fi; "
	-- [[ ]] rather than ' ' so a name containing an apostrophe survives the Lua string it lands in
	local command = vars
		.. 'hyprctl dispatch "hl.dsp.workspace.rename({ workspace = $WORKSPACE_ID, name = [[$FINAL_NAME]] })"'

	hl.exec_cmd(command)
end)
