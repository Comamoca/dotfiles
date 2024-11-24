if vim.loader then
  vim.loader.enable()
end

-- start prelude
local dpp_src = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp.vim"
vim.opt.runtimepath:prepend(dpp_src)

local dpp = require("dpp")
-- end prelude

-- local dpp_base = "~/.cache/dpp/"
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

-- local fn = vim.fn

-- call dpp#min#load_state("~/.cache/dpp")
-- call dpp#make_state("~/.cache/dpp", "~/.config/nvim/dpp.ts")
if dpp.load_state(dppBase) then
  vim.api.nvim_create_autocmd("User", {
    pattern = "DenopsReady",
    callback = function()
      vim.notify("dpp load_state() is failed")
      dpp.make_state(dppBase, dpp_config)
    end,
  })
end

-- dpp.load_state("~/.cache/dpp")
-- dpp.make_state("~/.cache/dpp", "~/.config/nvim/dpp.ts")

-- vim.api.nvim_create_autocmd("User", {
--   pattern = "Dpp:makeStatePost",
--   callback = function()
--     vim.notify("dpp make_state() is done")
--   end,
-- })

-- autocmd BufRead *.rs let g:rustfmt_autosave = 0
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

vim.cmd("filetype indent plugin on")
vim.cmd("syntax on")

vim.api.nvim_create_user_command("DppInstall", "call dpp#async_ext_action('installer', 'install')", { nargs = 0 })
vim.api.nvim_create_user_command("DppUpdate", "call dpp#async_ext_action('installer', 'update')", { nargs = 0 })
vim.api.nvim_create_user_command("DppMakestate", function(val)
  dpp.make_state(dppBase, dpp_config)
end, { nargs = 0 })

vim.api.nvim_create_user_command("Ddu", function(args)
  local subcmd = args.args
  print(subcmd)
  vim.fn["ddu#start"]({ sources = { { name = subcmd } } })
end, { nargs = 1 })

vim.api.nvim_create_autocmd({ "BufRead", "CursorHold", "InsertEnter" }, {
  callback = function()
    vim.opt.clipboard = "unnamedplus"
    require("configs/keymap")
    -- require("configs/cmd")

    -- vim.cmd("colorscheme gruvbox")
    -- vim.cmd("colorscheme wal")
    -- vim.cmd("colorscheme nord")
    -- vim.cmd("SeiyaEnable")
  end,
})

-- vim.g.seiya_auto_enable = 1

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

-- vim.opt.relativenumber = true

vim.cmd("set completeopt=menuone,noinsert")

vim.keymap.set("n", "<leader>k", function()
  print("Hop!")
end)

vim.cmd([[const mapleader = " "]])

vim.opt.runtimepath:append(vim.fn.expand("~/ghq/github.com/coma/memos.vim"))
vim.opt.runtimepath:append(vim.fn.expand("~/ghq/github.com/Comamoca/vimskey"))

-- vim.opt.runtimepath:append(vim.fn.expand("~/ghq/github.com/Comamoca/sandbox/fennel_nvim"))
-- vim.opt.runtimepath:append(vim.fn.expand("~/ghq/github.com/Comamoca/sandbox/calc.nvim"))
-- vim.opt.runtimepath:append(vim.fn.expand("~/ghq/github.com/Comamoca/sandbox/calc.nvim"))

vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/Comamoca/sandbox/ex_gleam_denops"))
vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/coma/vim-spotify"))
-- vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/coma/vim-palette"))
-- vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/coma/octagon.nvim"))
-- vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/coma/vim-repl"))
-- vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/coma/vim-task"))
-- vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/coma/vim-codecrop"))

-- ddu local
vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/Shougo/ddu-ui-ff"))
require("configs/ddu")

vim.opt.virtualedit = "none"

vim.cmd([[let maplocalleader = ' ']])

-- vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/Comamoca/sandbox/ex_gleam_denops"))
-- vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/coma/vim-yasunori"))

vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/Comamoca/vim-spotify"))
vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/coma/vim-moonbit-settings"))

vim.opt.expandtab = true

vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/coma/vim-junky"))
vim.g.junky_path = "~/.junky"

vim.opt.runtimepath:append(vim.fn.expand("~/.ghq/github.com/coma/vim-morg"))

vim.opt.foldmethod = "marker"

vim.api.nvim_create_autocmd("BufEnter", {
        pattern = {"*.md", "*.markdown"},
        callback = function ()
                vim.keymap.set("n", "<leader>er", "<cmd>call morg#run()<CR>")
        end
})

-- vim.g['denops_server_addr'] = "127.0.0.1:32123"
