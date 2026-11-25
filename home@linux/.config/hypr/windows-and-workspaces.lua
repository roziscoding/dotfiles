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

hl.window_rule({
	name = "spotatui-on-workspace-10",
	match = { class = "com.spotatui" },
	workspace = 10,
})

hl.window_rule({
	name = "cava-on-workspace-10",
	match = { class = "music.cava" },
	workspace = 10,
})

--- If the player window is not open or on a different workspace, open it or bring it to workspace 10
hl.on("workspace.active", function(ws)
	if ws.id ~= 10 then
		return
	end

	local player_window = hl.get_window("class:" .. PLAYER_WINDOW_CLASS)

	if not player_window then
		Notification.info("Launching music player", 1500)
		hl.exec_cmd(PLAYER_LAUNCH_COMMAND)
		return
	end

	if player_window and not (player_window.workspace.id == 10) then
		hl.dispatch(hl.dsp.window.move({
			window = player_window,
			workspace = 10,
		}))
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

-- Android emulator: tiled, the device screen gets cut off. The side toolbar and extended controls
-- float; the device window is pseudotiled (it keeps its own size inside the slot it reserves).
hl.window_rule({
	name = "float-android-emulator",
	match = { class = "^Emulator$", title = "^(Emulator|Extended Controls.*)$" },
	float = true,
})

-- Sizes the device window's tile to its own width plus room for the toolbar, which the emulator
-- puts on its right. Only for the common case of a side-by-side split with one other window.
local function fit_emulator_split(window, width)
	local workspace = window.workspace
	local monitor = workspace and workspace.monitor
	if not monitor then
		return
	end
	local others, toolbar = {}, nil
	for _, other in ipairs(hl.get_windows({ workspace = workspace.id })) do
		if other.class == "Emulator" and other.title == "Emulator" then
			toolbar = other
		elseif other.address ~= window.address and not other.floating then
			others[#others + 1] = other
		end
	end
	if #others ~= 1 then
		return
	end

	local outer = hl.get_config("general.gaps_out")
	local inner = hl.get_config("general.gaps_in").right
	local area = monitor.width - monitor.reserved.left - monitor.reserved.right - outer.left - outer.right
	-- The device is centered in its tile, so leave the toolbar's room on both sides.
	local slot = width + 2 * ((toolbar and toolbar.size.x or 0) + inner) + 2 * inner
	local share = slot / area
	-- The ratio sizes the first child of the split: area * ratio / 2.
	local ratio = window.at.x < others[1].at.x and 2 * share or 2 - 2 * share
	hl.dispatch(hl.dsp.focus({ window = window }))
	hl.dispatch(hl.dsp.layout(string.format("splitratio %.4f exact", math.max(0.1, math.min(1.9, ratio)))))
end

-- Both windows open titled "Emulator" and the device window is renamed afterwards, so the rule
-- above floats it too: tile and pseudotile it once its real title shows up.
hl.on("window.title", function(window)
	if not window or window.class ~= "Emulator" or not window.floating or not window.title:match("^Android Emulator") then
		return
	end
	local width = window.size.x
	hl.dispatch(hl.dsp.window.float({ action = "disable", window = window }))
	hl.dispatch(hl.dsp.window.pseudo({ window = window }))
	fit_emulator_split(window, width)
end)

hl.window_rule({
	match = { class = "openlogi-action-ring" },
	float = true,
	decorate = false,
	rounding = 0,
	no_blur = true,
})

-- Scratchpad
hl.bind(MAIN_MOD .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(MAIN_MOD .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Toggleable workspace
hl.bind(MAIN_MOD .. " + T", hl.dsp.workspace.toggle_special("toggleable"))
hl.bind(MAIN_MOD .. " + SHIFT + T", hl.dsp.window.move({ workspace = "special:toggleable" }))
