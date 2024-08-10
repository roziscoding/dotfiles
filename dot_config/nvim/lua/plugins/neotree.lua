return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader><leader>", "<cmd>Neotree filesystem reveal right<cr>", desc = "NeoTree" },
    { "<C-b>", "<cmd>Neotree toggle right<cr>", desc = "Show or hide neotree" },
  },
  opts = {
    window = {
      position = "right",
    },
    filesystem = {
      hijack_netrw_behavior = "open_current",
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("load_neo_tree", {}),
      desc = "Loads neo-tree when openning a directory",
      callback = function(args)
        local stats = vim.uv.fs_stat(args.file)

        if not stats or stats.type ~= "directory" then
          return
        end

        require "neo-tree"

        return true
      end,
    })
  end,
  config = function(_, opts)
    require("neo-tree").setup(opts)
    vim.api.nvim_create_augroup("load_neo_tree", {})
  end,
}
