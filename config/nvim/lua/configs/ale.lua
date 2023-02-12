vim.g.ale_fixers = {
	typescript = { "deno" },
	typescriptreact = { "deno" },
	javascript = { "deno" },
	javascriptreact = { "deno" },
	css = { "prettier" },
	python = { "autopep8", "black", "isort" },
	golang = { "gofmt" },
	lua = { "stylua" },
}
vim.g.ale_sign_error = "P>"
vim.g.ale_sign_warning = "P-"
vim.g.ale_echo_msg_format = "[%linter%] %code: %%s"
vim.g.ale_statusline_format = { "E%d", "W%d", "OK" }

vim.keymap.set("n", "<C-w>j", "<Plug>(ale_next_wrap)", {})
vim.keymap.set("n", "<C-w>k", "<Plug>(ale_previous_wrap", {})

vim.g.ale_fix_on_save = 1
vim.g.ale_javascript_prettier_use_local_config = 1
vim.g.ale_javascript_prettier_options = "--single-quote --trailing-comma all"

vim.g.ale_linters = {
	go = { "revive" },
	python = { "flake8", "pyre" },
	lua = { "luacheck" },
}
