require("notification")

TERMINAL = "ghostty"
FILE_MANAGER = "nautilus"
LAUNCHER_COMMAND = "vicinae toggle"
BROWSER_LAUNCH_COMMAND = "firefox-developer-edition"

Notification.try(
	function() require("global_overrides") end,
	function(err) return not string.find(err, "not found") end
)
