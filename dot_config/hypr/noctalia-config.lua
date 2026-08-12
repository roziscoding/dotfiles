hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,
  },

  decoration = {
    rounding = 20,
    rounding_power = 2,

    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = 0xee1a1a1a,
    },

    blur = {
      enabled = true,
      size = 3,
      passes = 2,
      vibrancy = 0.1696,
    },
  },
})

local noctalia = require("noctalia")

hl.window_rule({
  name = "scratchpad-borders",
  match = { workspace = "special:magic" },
  border_size = 3,
  border_color = noctalia.colors.error .. " " .. noctalia.colors.surface,
})
