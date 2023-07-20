local lsp = require("lspconfig")

vim.tbl_deep_extend("keep", lsp, {
	kuqi = {
		cmd = { "kuqi" },
		filetypes = "cotowali",
		name = "kuqi",
	},
})
