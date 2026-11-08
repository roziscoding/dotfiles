require("notification")

MAIN_MOD = "ALT" -- Sets Alt key as main modifier
TERMINAL = "ghostty"
FILE_MANAGER = "nautilus"
LAUNCHER_COMMAND = "vicinae toggle"
BROWSER_LAUNCH_COMMAND = "firefox-developer-edition"
PLAYER_WINDOW_CLASS = "spotify"
PLAYER_LAUNCH_COMMAND = "flatpak run com.spotify.Client"

Notification.try(
	function() require("global_overrides") end,
	function(err) return not string.find(err, "not found") end
)
