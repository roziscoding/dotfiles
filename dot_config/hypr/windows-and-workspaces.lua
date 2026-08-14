--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
require("globals")
require("notification")

local suppressMaximizeRule = hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
suppressMaximizeRule:set_enabled(true)

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Keep chat apps on the scratchpad (special:magic).
hl.window_rule({
	name = "slack-to-scratchpad",
	match = { class = "com.slack.Slack" },

	workspace = "special:magic",
})

hl.window_rule({
	name = "discord-to-scratchpad",
	match = { class = "discord" },

	workspace = "special:magic",
})

hl.window_rule({
	name = "telegram-to-scratchpad",
	match = { class = "org.telegram.desktop" },

	workspace = "special:magic",
})

---Fixed Workspaces

--- Music
local player_window_class = "spotify"
local player_launch_command = "flatpak run com.spotify.Client"

hl.workspace_rule({
	workspace = "10",
	persistent = true,
	default_name = "󰝚",
})

hl.window_rule({
	name = "spotify-on-workspace-10",
	match = { class = "spotify" },
	workspace = 10,
})

--- If the player window is not open or on a different workspace, open it or bring it to workspace 10
hl.on("workspace.active", function(ws)
	if ws.id ~= 10 then
		return
	end

	local player_window = hl.get_window("class:" .. player_window_class)

	if not player_window then
		Notification.info("Launching music player")
		hl.exec_cmd(player_launch_command)
		return
	end

	if player_window and not (player_window.workspace.id == 10) then
		hl.dispatch(
			hl.dsp.window.move({
				window = player_window,
				workspace = 10
			})
		)
	end
end)

--- Browser

hl.workspace_rule({
	workspace = "9",
	persistent = true,
	default_name = "󰖟",
})

hl.window_rule({
	name = "firefox-on-9",
	match = { class = "firefox-developer-edition" },
	workspace = 9,
})

hl.window_rule({
	name = "chrome-on-9",
	match = { class = "google-chrome" },
	workspace = 9,
})

hl.on("workspace.active", function(ws)
	if ws.id ~= 9 then
		return
	end

	local windows = hl.get_windows({ workspace = 9 })

	if #windows == 0 then
		Notification.info("Starting default browser", 1500)
		hl.exec_cmd(BROWSER_LAUNCH_COMMAND)
	end
end)

-- Float YAD windows
hl.window_rule({
	match = { class = "yad" },
	float = true,
})
