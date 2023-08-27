if vim.loader then
	vim.loader.enable()
end
vim.g.loaded_luv = true

local dein = require("comatools/dein")
require("comatools/lazyload")

local dein_toml_dir = "/home/coma/" .. ".config/nvim/"

local dein_toml = dein_toml_dir .. "dein.toml"
local dein_toml_lazy = dein_toml_dir .. "dein_lazy.toml"

local function toTomlPath(filename)
	return dein_toml_dir .. filename
end

dein.prelude(function()
	-- vim.call("dein#load_toml", dein_toml, { lazy = 0 })
	-- vim.call("dein#load_toml", dein_toml_lazy, { lazy = 1 })

	-- vim.call("dein#load_toml", toTomlPath("lsp.toml"), { lazy = 1 })
	-- vim.call("dein#load_toml", toTomlPath("ft.toml"), { lazy = 1 })
	-- vim.call("dein#load_toml", toTomlPath("dap.toml"), { lazy = 1 })
	-- vim.call("dein#load_toml", toTomlPath("ddu.toml"), { lazy = 1 })
	-- vim.call("dein#load_toml", toTomlPath("openai.toml"), { lazy = 1 })

	dein.load_toml({
		{
			path = dein_toml,
			lazy = 0,
		},
		{
			path = dein_toml_lazy,
			lazy = 1,
		},
		{
			path = toTomlPath("lsp.toml"),
			lazy = 1,
		},
		{
			path = toTomlPath("ft.toml"),
			lazy = 1,
		},
		{
			path = toTomlPath("dap.toml"),
			lazy = 1,
		},
		{
			path = toTomlPath("ddu.toml"),
			lazy = 1,
		},
		{
			path = toTomlPath("openai.toml"),
			lazy = 1,
		},
	})

	-- dein.add("~/ghq/github.com/Allianaab2m/vimskey")
	-- dein.add("~/ghq/github.com/coma/ddu-configs")
	-- dein.add("~/ghq/github.com/Comamoca/sandbox/sample_picker")
	-- dein.add("~/ghq/github.com/Comamoca/sandbox/ruby-plugin")
	-- dein.add("~/ghq/github.com/Comamoca/sandbox/denops-sample")

	vim.call("dein#begin", dein_dir)
	local plugins = {
		{
			name = "~/ghq/github.com/Allianaab2m/vimskey",
			config = function() end,
		},
		{
			name = "~/ghq/github.com/coma/ddu-configs",
			config = function() end,
		},
		{
			name = "~/ghq/github.com/Comamoca/sandbox/sample_picker",
			config = function() end,
		},
		{
			name = "~/ghq/github.com/Comamoca/sandbox/ruby-plugin",
			config = function() end,
		},
		{
			name = "~/ghq/github.com/Comamoca/sandbox/denops-sample",
			config = function() end,
		},
	}

	for _, plugin in ipairs(plugins) do
		dein.add(plugin.name)
	end
end)

-- vim.call("dein#add", "~/ghq/github.com/coma/mr-telescope")
-- vim.call("dein#add", "~/ghq/github.com/vim-denops/denops.vim")
-- vim.call("dein#add", "~/ghq/github.com/coma/gpt.vim")

-- vim.call("dein#add", "~/ghq/github.com/coma/fmt.nvim")

require("configs/cmds")
require("configs/keybind")
-- require("configs/splash")
require("comatools/kit")
require("comatools/cloma")

vim.scriptencoding = "utf-8"

vim.g.gruvbox_material_transparent_background = 1

if not vim.g.vscode then
	vim.cmd.colorscheme("gruvbox-material")
	-- vim.cmd.colorscheme("labcoat")
	-- vim.cmd.colorscheme("neodark")
	-- vim.cmd.colorscheme("terafox")
	-- vim.cmd.colorscheme("nordfox")
	-- vim.cmd.colorscheme("gotham")
	-- vim.cmd.colorscheme("challenger_deep")
end

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
" au BufRead,FileType  *.tl set filetype=teal

au BufRead,FileType  *.nim set foldmethod=marker

au FileType vue syntax sync fromstart
autocmd TermOpen * setlocal norelativenumber
autocmd TermOpen * setlocal nonumber
]])

vim.g.comfortable_motion_no_default_key_mappings = 1

-- enable denops debugmode
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

vim.opt.cmdheight = 0
