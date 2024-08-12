return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")

		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
			},
		})
	end,
	keys = {
		{ "<M-F>", vim.lsp.buf.format, desc = "NeoTree" },
	},
}
