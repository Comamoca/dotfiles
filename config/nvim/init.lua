local dpp_src = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp.vim"
vim.opt.runtimepath:prepend(dpp_src)
local dpp = require("dpp")

local dpp_base = "~/.cache/dpp/"
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

local dpp = require("dpp")

vim.opt.runtimepath:prepend(denops_src)

local dppBase = "~/.cache/dpp"

if dpp.load_state(dppBase) then
  vim.api.nvim_create_autocmd("User", {
    pattern = "DenopsReady",
    callback = function()
      vim.notify("dpp load_state() is failed")
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

vim.cmd("filetype indent plugin on")
vim.cmd("syntax on")

vim.api.nvim_create_user_command("DppInstall", "call dpp#async_ext_action('installer', 'install')", { nargs = 0 })
vim.api.nvim_create_user_command("DppUpdate", "call dpp#async_ext_action('installer', 'update')", { nargs = 0 })

vim.api.nvim_create_user_command("Ddu", function(args)
  local subcmd = args.args
  print(subcmd)
  vim.fn["ddu#start"]({ sources = { { name = subcmd } } })
end, { nargs = 1 })

vim.api.nvim_create_autocmd({ "BufRead", "CursorHold", "InsertEnter" }, {
  callback = function()
    -- vim.opt.clipboard = "unnamedplus"
    -- if vim.fn.has("wsl") then
    --   vim.g.clipboard = {
    --     name = "win32yank-wsl",
    --     copy = {
    --       ["+"] = "win32yank.exe -i --crlf",
    --       ["*"] = "win32yank.exe -i --crlf",
    --     },
    --     paste = {
    --       ["+"] = "win32yank.exe -o --crlf",
    --       ["*"] = "win32yank.exe -o --crlf",
    --     },
    --     cache_enable = 0,
    --   }
    -- end

    require("configs/keymap")
    -- require("configs/cmd")

    -- vim.cmd("colorscheme gruvbox")
    vim.cmd("colorscheme kanagawa-wave")
    vim.cmd("SeiyaEnable")
  end,
})

vim.g.mapleader = " "

vim.cmd("inoremap jj <C-[>")
vim.cmd("nnoremap <C-[><C-[> <cmd>noh<CR>")
vim.cmd("let g:seiya_auto_enable=1")
vim.cmd("nnoremap sv <cmd>vs<CR>")
vim.cmd("nnoremap s <C-w>")
vim.cmd("set ignorecase")

vim.cmd("au FileType * setlocal formatoptions-=ro")

vim.opt.runtimepath:append(vim.fn.expand("~/ghq/github.com/coma/memos.vim"))
vim.opt.runtimepath:append(vim.fn.expand("~/ghq/github.com/Comamoca/vimskey"))

-- vim.opt.runtimepath:append(vim.fn.expand("~/ghq/github.com/Comamoca/sandbox/fennel_nvim"))
vim.opt.runtimepath:append(vim.fn.expand("~/ghq/github.com/Comamoca/sandbox/calc.nvim"))
vim.opt.clipboard = "unnamedplus"

vim.cmd("set completeopt=menuone,noinsert")

vim.g.denops_server_addr = '127.0.0.1:32123'

vim.cmd([[
function s:dduCustom(items, callback)
	call ddu#start({'sources': [
		\  {'name': 'custom-list',
		\   'params': {'texts': a:items, 'callbackId': a:callback}}]})
endfunction

function s:openConfig() abort 
    const configs = map(
    \  split(glob("~/.config/nvim/*"), "\n"),
    \  "substitute(v:val, printf('%s/.vim/', $HOME), '', 'g')")

    const configedit = denops#callback#register(
        \ {s -> execute(printf('e ~/.vim/%s', s), '')},
        \ {'once': v:true})
    
    call s:dduCustom(configs, configedit)
endfunction

command! Configs call s:openConfig()
]])
