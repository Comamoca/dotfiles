-- dein.vim loading script
-- {{{
local dein_dir = vim.env.HOME .. "/.cache/dein"
local dein_repo_dir = dein_dir .. "/repos/github.com/Shougo/dein.vim"

if not string.match(vim.o.runtimepath, "/dein.vim") then
	if vim.fn.isdirectory(dein_repo_dir) ~= 1 then
		os.execute("git clone https://github.com/Shougo/dein.vim " .. dein_repo_dir)
	end
	vim.o.runtimepath = dein_repo_dir .. "," .. vim.o.runtimepath
end

if vim.call("dein#load_state", dein_dir) == 1 then
	local dein_toml_dir = vim.env.HOME .. "/.config/nvim/"

	local dein_toml = dein_toml_dir .. "dein.toml"
	local dein_toml_lazy = dein_toml_dir .. "dein_lazy.toml"

	vim.call("dein#begin", dein_dir)
	vim.call("dein#load_toml", dein_toml, { lazy = 0 })
	vim.call("dein#load_toml", dein_toml_lazy, { lazy = 1 })
	vim.call("dein#load_toml", dein_toml_dir .. "ddu.toml", { lazy = 1 })
	vim.call("dein#load_toml", dein_toml_dir .. "lsp.toml", { lazy = 0 })
	vim.call("dein#add", "~/ghq/github.com/Allianaab2m/vimskey")
	vim.call("dein#add", "~/ghq/github.com/coma/ddu-configs")
	vim.call("dein#add", "~/ghq/github.com/coma/gpt.vim")
	vim.call("dein#end")
	vim.call("dein#save_state")
end
-- }}}

-- require("configs/loader").loadConf()
require("configs/cmds")
require("configs/keybind")
require("configs/splash")
-- require("comatools").setup()

-- base
vim.scriptencoding = "utf-8"
vim.wo.number = true

-- vim.cmd "colorscheme gruvbox"
-- vim.cmd "highlight Normal ctermbg=none"
vim.cmd("set nocompatible")
vim.cmd("set wildmenu")
vim.cmd("set ignorecase")
vim.cmd("set runtimepath+=~/.config/nvim/lua")
vim.cmd("let g:python3_host_prog = '/usr/sbin/python3'")
-- vim.cmd("let g:denops#deno = '/home/coma/.deno/bin/deno'")

vim.cmd("let g:comfortable_motion_no_default_key_mappings = 1")
vim.opt.ambiwidth = "single"

vim.cmd([[
set clipboard&
set clipboard^=unnamedplus
]])

vim.cmd([[
set foldmethod=marker
set foldcolumn=3
]])

vim.cmd("set scrolloff=9999")

vim.opt.laststatus = 3

vim.cmd("let $OPENAI_API_KEY = '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'")

-- vim.cmd.colorscheme("catppuccin")
vim.cmd.colorscheme("gruvbox-material")
vim.g.seiya_auto_enable = 1
