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

    telescope.load_extension("chezmoi")
  end,
  keys = {
    { "<leader>cz", require("telescope").extensions.chezmoi.find_files, "Find files managed by chezmoi" },
  },
}
