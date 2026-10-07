if vim.loader then
  vim.loader.enable()
end

-- start prelude
local dpp_src = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp.vim"
vim.opt.runtimepath:prepend(dpp_src)

local dpp = require("dpp")
-- end prelude

local dppBase = "~/.cache/dpp"
local dpp_config = "~/.config/nvim/dpp.ts"
local denops_src = "~/.cache/dpp/repos/github.com/vim-denops/denops.vim"

local ext_toml = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp-ext-toml"
local ext_lazy = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp-ext-lazy"
local ext_installer = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp-ext-installer"
local ext_git = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp-protocol-git"

vim.opt.runtimepath:append(ext_toml)
vim.opt.runtimepath:append(ext_lazy)
vim.opt.runtimepath:append(ext_installer)
vim.opt.runtimepath:append(ext_git)
vim.opt.runtimepath:prepend(denops_src)

if dpp.load_state(dppBase) then
  vim.api.nvim_create_autocmd("User", {
    pattern = "DenopsReady",
    callback = function()
      vim.notify("dpp: Rebuilding plugin state cache...", vim.log.levels.INFO)
      dpp.make_state(dppBase, dpp_config)
    end,
  })
end

vim.api.nvim_create_autocmd("User", {
  pattern = "Dpp:makeStatePost",
  callback = function()
    vim.notify("dpp make_state() is done")
  end,
})

---------------------------------------------------------

vim.opt.runtimepath:append(vim.fn.expand("~/.config/nvim"))
-- nvim-treesitter install_dir must be in rtp before lazy loading
vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/site")
-- Nix-managed nvim-treesitter: all parsers (326) + queries bundled via symlinkJoin
vim.opt.runtimepath:prepend(vim.fn.expand("~/.cache/dpp/_generated/nvim-treesitter"))

vim.api.nvim_create_autocmd("BufRead", {
  pattern = "*.ab",
  command = "set filetype=amber",
})

vim.api.nvim_create_autocmd("BufRead", {
  pattern = "*.astro",
  command = "set filetype=astro",
})

vim.api.nvim_create_autocmd("BufRead", {
  pattern = "*.mbt",
  callback = function()
    vim.bo.filetype = "moonbit"

    local quickrun_config = vim.g.quickrun_config
    local moonbit = vim.fn["moonbit_settings#moonbit_quickrun"]()

    -- Vim scriptとLua間で辞書型/table型を操作するのが上手くいかない
    vim.g.quickrun_config["moonbit"] = moonbit
    vim.print(vim.g.quickrun_config)
  end,
})

vim.api.nvim_create_autocmd("BufRead", {
  pattern = "rebar.config",
  command = "set filetype=erlang",
})

vim.cmd("filetype indent plugin on")
vim.cmd("syntax on")

vim.api.nvim_create_user_command("DppInstall", "call dpp#async_ext_action('installer', 'install')", { nargs = 0 })
vim.api.nvim_create_user_command("DppUpdate", "call dpp#async_ext_action('installer', 'update')", { nargs = 0 })
vim.api.nvim_create_user_command("DppMakestate", function(val)
  dpp.make_state(dppBase, dpp_config)
end, { nargs = 0 })

-- Install treesitter parsers with new API
vim.api.nvim_create_user_command("TSInstallParsers", function(args)
  local parsers = vim.split(args.args, " ", { trimempty = true })
  if #parsers == 0 then
    parsers = { "c", "lua", "vim", "vimdoc", "query", "gleam" }
  end
  require("nvim-treesitter").install(parsers)
end, {
  nargs = "*",
  desc = "Install treesitter parsers",
})

vim.api.nvim_create_user_command("Ddu", function(args)
  local subcmd = args.args
  print(subcmd)
  vim.fn["ddu#start"]({ sources = { { name = subcmd } } })
end, { nargs = 1 })

vim.api.nvim_create_autocmd({ "BufRead", "CursorHold", "InsertEnter" }, {
  callback = function()
    vim.opt.clipboard = "unnamedplus"
    require("configs/keymap")
  end,
})

vim.cmd("inoremap jj <C-[>")
vim.cmd("nnoremap <C-[><C-[> <cmd>noh<CR>")
vim.cmd("nnoremap sv <cmd>vs<CR>")
vim.cmd("nnoremap s <C-w>")
vim.cmd("set ignorecase")
vim.cmd("set termguicolors")

vim.cmd("au FileType * setlocal formatoptions-=r")
vim.cmd("au FileType * setlocal formatoptions-=o")
vim.cmd("au FileType *.hx set ft=haxe")

vim.cmd("au BufRead .denoflare set filetype=json")

vim.opt.laststatus = 3
vim.opt.cursorline = true

vim.cmd("set completeopt+=noinsert")

vim.keymap.set("n", "<leader>k", function()
  print("Hop!")
end)

vim.cmd([[const mapleader = " "]])

vim.opt.runtimepath:append(vim.fn.expand("~/ghq/github.com/coma/memos.vim"))
vim.opt.runtimepath:append(vim.fn.expand("~/ghq/github.com/Comamoca/vimskey"))

vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/Comamoca/sandbox/ex_gleam_denops"))
vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/coma/vim-spotify"))

vim.opt.virtualedit = "none"

vim.cmd([[let maplocalleader = ' ']])

vim.opt.expandtab = true

vim.opt.foldmethod = "marker"

vim.opt.foldmethod = "marker"

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.md", "*.markdown" },
  callback = function()
    vim.keymap.set("n", "<leader>er", "<cmd>call morg#run()<CR>")
  end,
})

vim.api.nvim_create_user_command("Init", "e $MYVIMRC", {})
vim.api.nvim_create_user_command("Scratch", function()
  require("snacks").scratch()
end, {})

----- Neovide -----

if vim.g.neovide then
  vim.g.neovide_cursor_vfx_mode = "torpedo"
  vim.o.background = "dark"
  vim.g.neovide_theme = "dark"

  local bg = "#1e1e2e"

  for _, group in ipairs({
    "Normal",
    "NormalNC",
    "NormalFloat",
    "SignColumn",
    "EndOfBuffer",
  }) do
    vim.api.nvim_set_hl(0, group, { bg = bg })
  end
end
