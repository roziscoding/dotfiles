return {
  "xvzc/chezmoi.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("chezmoi").setup({
      edit = {
        watch = false,
        force = false,
      },
      notification = {
        on_open = true,
        on_apply = true,
        on_watch = true,
      },
      telescope = {
        select = { "<CR>" },
      },
    })

    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/*" },
      callback = function()
        vim.schedule(require("chezmoi.commands.__edit").watch)
      end,
    })
  end,
}
