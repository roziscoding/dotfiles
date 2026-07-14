require("globals") -- shared `hl` API handle + program vars (terminal, file manager, menu)

----------------
----  MISC  ----
----------------

hl.config({
	misc = {
		force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = false, -- If true disables the random hyprland logo / anime girl background. :(
	},
})

require("monitors") -- display layout: output, resolution/mode, position, scale
require("autostart") -- commands run on hyprland start (noctalia, openrgb)
require("look-and-feel") -- appearance: cursor size, gaps, borders, decoration, blur/shadow, animations, layouts, scratchpad border
require("input") -- keyboard/mouse/touchpad: layout, follow-mouse, sensitivity, natural scroll
require("windows-and-workspaces") -- window rules: suppress-maximize, xwayland drag fix, hyprland-run placement

require("noctalia").apply_theme() -- applies noctalia color theme to window/group borders
require("keybindings") -- all key binds (mainMod = ALT)
