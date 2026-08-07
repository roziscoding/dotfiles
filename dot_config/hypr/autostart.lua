require("globals")
-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function()
	hl.exec_cmd("noctalia")
	hl.exec_cmd(
		"openrgb --mode direct --color \"$(cat $(find ~/.config/noctalia/palettes -name '*.json' -print -quit) | jq '.dark.mOnError' -r | tr -d \\#)\""
	)
end)
