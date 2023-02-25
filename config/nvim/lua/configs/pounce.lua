require("pounce").setup({
	accept_keys = "JFKDLSAHGNUVRBYTMICEOXWPQZ",
	accept_best_key = "<enter>",
	multi_window = true,
	debug = false,
})

vim.cmd("nnoremap s :<c-u>Pounce<CR>")
