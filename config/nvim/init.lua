if vim.loader then
	vim.loader.enable()
end
vim.g.loaded_luv = true

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
	vim.call("dein#load_toml", dein_toml_dir .. "lsp.toml", { lazy = 1 })
	vim.call("dein#load_toml", dein_toml_dir .. "ft.toml", { lazy = 1 })
	vim.call("dein#load_toml", dein_toml_dir .. "dap.toml", { lazy = 1 })
	vim.call("dein#load_toml", dein_toml_dir .. "openai.toml", { lazy = 1 })

	vim.call("dein#add", "~/ghq/github.com/Allianaab2m/vimskey")
	vim.call("dein#add", "~/ghq/github.com/coma/ddu-configs")
	-- vim.call("dein#add", "~/ghq/github.com/vim-denops/denops.vim")
	-- vim.call("dein#add", "~/ghq/github.com/coma/gpt.vim")

	vim.call("dein#end")
	vim.call("dein#save_state")
end
-- }}}

require("configs/cmds")
require("configs/keybind")

-- require("configs/splash")

require("comatools/lazyload")
require("comatools/kit")
require("comatools/cloma")
-- base
vim.scriptencoding = "utf-8"
-- vim.wo.number = true

vim.g.gruvbox_material_transparent_background = 1

if not vim.g.vscode then
	vim.cmd.colorscheme("gruvbox-material")
end

-- vim.cmd.colorscheme("everforest")
-- vim.cmd.colorscheme("gruvbox")
-- vim.cmd.colorscheme("habamax")
-- vim.cmd.colorscheme("torte")

vim.opt.termguicolors = true

vim.opt.list = true
vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")

vim.cmd([[
        set foldmethod=marker
        set foldcolumn=3
]])

vim.cmd("let g:python3_host_prog = '/usr/sbin/python3'")

LazyLoad("BufRead", function()
	vim.cmd([[
	set clipboard&
	set clipboard^=unnamedplus
	]])

	vim.cmd("set wildmenu")

	vim.keymap.set("n", "C-f", ":clo" .. "<CR>", { noremap = true, silent = true })
end)

LazyLoad("VimEnter", function()
	vim.cmd("set nocompatible")
	vim.cmd("set ignorecase")
	vim.cmd("let g:comfortable_motion_no_default_key_mappings = 1")

	vim.opt.ambiwidth = "single"
	vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
end)
vim.opt.laststatus = 0

vim.g.seiya_auto_enable = 1

-- vim.api.nvim_create_augroup("lua", {})
-- vim.api.nvim_create_autocmd({ "FileType  *.go" }, {
-- 	group = "lua",
-- 	callback = function()
-- 		vim.opt.wrap = false
-- 	end,
-- })

-- vim.api.nvim_create_augroup("crystal", {})

vim.cmd([[
" au BufRead,BufNewFile *.ex,*.exs set filetype=elixir
au BufRead,BufNewFile *.eex,*.heex,*.leex,*.sface,*.lexs set filetype=eelixir
au BufRead,BufNewFile mix.lock set filetype=elixir
au BufRead,FileType  *.go set wrap
au BufRead,FileType  *.lark set filetype=lark
au BufRead,FileType  *.er set filetype=erg

au FileType vue syntax sync fromstart
autocmd TermOpen * setlocal norelativenumber
autocmd TermOpen * setlocal nonumber
]])

vim.g.comfortable_motion_no_default_key_mappings = 1
-- vim.cmd [[highlight IndentBlanklineChar guifg=#56B6C2 gui=nocombine]]

-- vim.cmd("let g:denops_server_addr = '127.0.0.1:32123'")
-- vim.cmd("let g:denops#debug = 1")
-- vim.cmd("let g:denops_server_addr = '127.0.0.1:32123'")
-- vim.cmd("let g:denops#debug = 1")

if vim.g.neovide then
	vim.o.guifont = "UDEV Gothic NFLG Regular:h7"

	local alpha = function()
		return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
	end
	-- g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
	vim.g.neovide_transparency = 0.8
	vim.g.transparency = 0.8
	vim.g.neovide_background_color = "#0f1117" .. alpha()
	-- vim.wo.number = true
end
