if vim.loader then vim.loader.enable() end

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
require("configs/splash")

require("comatools/lazyload")
-- base
vim.scriptencoding = "utf-8"
vim.wo.number = true

vim.g.gruvbox_material_transparent_background = 1
vim.cmd.colorscheme("gruvbox-material")
-- vim.cmd.colorscheme("gruvbox")
-- vim.cmd.colorscheme("habamax")
-- vim.cmd.colorscheme("torte")

vim.opt.termguicolors = true

vim.opt.list = true
vim.opt.listchars:append "space:⋅"
vim.opt.listchars:append "eol:↴"

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
	vim.opt.laststatus = 3

end)

vim.g.seiya_auto_enable = 1

vim.api.nvim_create_augroup( 'lua', {} )
vim.api.nvim_create_autocmd( {"FileType  *.go"}, {
  group = 'lua',
  callback = function() vim.opt.wrap = false end
})

vim.api.nvim_create_augroup("crystal", {})

vim.cmd([[
" au BufRead,BufNewFile *.ex,*.exs set filetype=elixir
au BufRead,BufNewFile *.eex,*.heex,*.leex,*.sface,*.lexs set filetype=eelixir
au BufRead,BufNewFile mix.lock set filetype=elixir
]])

-- vim.cmd [[highlight IndentBlanklineChar guifg=#56B6C2 gui=nocombine]]

-- vim.cmd("let g:denops_server_addr = '127.0.0.1:32123'")
-- vim.cmd("let g:denops#debug = 1")

vim.cmd [[autocmd FileType vue setlocal filetype=vue.html.javascript.css]]
