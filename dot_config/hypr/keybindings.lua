require("globals")
require("notification")
---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "ALT" -- Sets Alt key as main modifier

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(TERMINAL))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(FILE_MANAGER))
hl.bind(mainMod .. " + F", function()
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
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(LAUNCHER_COMMAND))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Move windows with mainMod + arrow keys
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Go to fixed workspaces
hl.bind(mainMod .. " + m", hl.dsp.focus({ workspace = "10" }))
hl.bind(mainMod .. " + b", hl.dsp.focus({ workspace = "9" }))

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Lock screen
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("noctalia msg session lock"))

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
hl.bind(mainMod .. " + SHIFT + CONTROL + 4", screenshot({ "region" }))
-- Window
hl.bind(mainMod .. " + SHIFT + CONTROL + 3", screenshot({ "window" }))
-- Screen
hl.bind(mainMod .. " + SHIFT + CONTROL + 2", screenshot({ "output", "active" }))

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
	mainMod .. "+ SHIFT + C",
	hl.dsp.exec_cmd("vicinae vicinae://launch/@ShyAssassin/store.vicinae.vscode-recents/open-recents")
)

-- Clipboard history with vicinae
hl.bind(mainMod .. "+ SHIFT + V", hl.dsp.exec_cmd("vicinae vicinae://launch/clipboard/history"))

-- Rename current workspace
hl.bind(mainMod .. "+ SHIFT + F2", function ()
	local workspace = hl.get_active_workspace()
	if not workspace then
		Notification.error("No active workspace")
		return
	end

	local yad_command = "yad --no-buttons --no-escape --borders 20 --entry"
	local command = "hyprctl dispatch \"hl.dsp.workspace.rename({ workspace = " .. workspace.id .. ", name = \\\"$(" ..  yad_command .. ")\\\" })\""

	print(yad_command)
	print(command)
	hl.exec_cmd(command)
end)