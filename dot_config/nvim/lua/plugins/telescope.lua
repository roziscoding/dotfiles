return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      file_ignore_patterns = {
        "node_modules",
        ".git",
      },
    },
  },
  config = function(opts)
    local telescope = require("telescope")
    telescope.setup(opts)
  end,
}
