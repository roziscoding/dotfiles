require("globals")
------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
	output = "DP-2",
	mode = "1920x1080@60.00Hz",
	position = "auto",
	scale = "auto",
})

hl.monitor({
	output = "eDP-1",
	disabled = true,
})
