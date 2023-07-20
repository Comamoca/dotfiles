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
	vim.call("dein#add", "~/ghq/github.com/Comamoca/sandbox/sample_picker")
	vim.call("dein#add", "~/ghq/github.com/coma/mr-telescope")
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
-- require("comatools/color")
-- base
vim.scriptencoding = "utf-8"
-- vim.wo.number = true

vim.g.gruvbox_material_transparent_background = 1

if not vim.g.vscode then
	-- vim.cmd.colorscheme("gruvbox-material")
	-- vim.cmd.colorscheme("labcoat")
	vim.cmd.colorscheme("neodark")
	-- vim.cmd.colorscheme("terafox")
	-- vim.cmd.colorscheme("nordfox")
	-- vim.cmd.colorscheme("gotham")
end

-- require("base16-colorscheme").setup({
-- 	base00 = "#3B3228",
-- 	base01 = "#534636",
-- 	base02 = "#645240",
-- 	base03 = "#7e705a",
-- 	base04 = "#b8afad",
-- 	base05 = "#d0c8c6",
-- 	base06 = "#e9e1dd",
-- 	base07 = "#f5eeeb",
-- 	base08 = "#cb6077",
-- 	base09 = "#d28b71",
-- 	base0A = "#f4bc87",
-- 	base0B = "#beb55b",
-- 	base0C = "#7bbda4",
-- 	base0D = "#8ab3b5",
-- 	base0E = "#a89bb9",
-- 	base0F = "#bb9584",
-- })

-- vim.cmd.colorscheme("everforest")
-- vim.cmd.colorscheme("gruvbox")
-- vim.cmd.colorscheme("habamax")

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

-- LazyLoad("FileType  cotowali", function()
-- 	require("configs/kuqi")
-- end)

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
au BufRead,FileType  *.li set filetype=cotowali
au BufRead,FileType  *.cr set filetype=crystal
au BufRead,FileType  *.v set filetype=v
au BufRead,FileType  *.hx set filetype=haxe
au BufRead,FileType  *.vsh set filetype=vsh

au BufRead,FileType  *.nim set foldmethod=marker

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

-- vim.cmd("set winblend=30")
vim.cmd(":set foldmethod=marker")
vim.cmd("let g:UltiSnipsSnippetDirectories = [$HOME.'/.config/nvim/ultisnip/']")

function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end
