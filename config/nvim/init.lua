-- dpp setup start
local dpp_base = "~/.cache/dpp/"
local dpp_src = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp.vim"
local dpp_config = "~/.config/nvim/dpp.ts"


local denops_src = "$HOME/.cache/dpp/repos/github.com/vim-denops/denops.vim"

local ext_toml = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp-ext-toml"
local ext_lazy = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp-ext-lazy"
local ext_installer = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp-ext-installer"
local ext_git = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp-protocol-git"

vim.opt.runtimepath:prepend(dpp_src)

vim.opt.runtimepath:append(ext_toml)
vim.opt.runtimepath:append(ext_git)
vim.opt.runtimepath:append(ext_lazy)
vim.opt.runtimepath:append(ext_installer)

vim.g.denops_server_addr = '127.0.0.1:34141'

if vim.fn["dpp#min#load_state"](dpp_base) then
  vim.opt.runtimepath:prepend(denops_src)

  vim.api.nvim_create_augroup("dpp", {})

  vim.cmd(string.format("autocmd User DenopsReady call dpp#make_state('%s', '%s')", dpp_base, dpp_config))
end
-- dpp setup end

vim.api.nvim_create_user_command("DppInstall", "call dpp#async_ext_action('installer', 'install')", { nargs = 0 })
vim.api.nvim_create_user_command("DppUpdate", "call dpp#async_ext_action('installer', 'update')", { nargs = 0 })
vim.opt.ignorecase = true
vim.opt.completeopt = { "menuone", "noinsert" }

vim.api.nvim_create_autocmd({ "BufRead", "CursorHold", "InsertEnter" }, {
  callback = function()
    vim.cmd.colorscheme("gruvbox")
    vim.cmd("SeiyaEnable")

    vim.opt.clipboard = "unnamedplus"
    if vim.fn.has("wsl") then
      vim.g.clipboard = {
        name = "win32yank-wsl",
        copy = {
          ["+"] = "win32yank.exe -i --crlf",
          ["*"] = "win32yank.exe -i --crlf",
        },
        paste = {
          ["+"] = "win32yank.exe -o --crlf",
          ["*"] = "win32yank.exe -o --crlf",
        },
        cache_enable = 0,
      }
    end

    require("configs/keymap")
    require("configs/cmd")
  end,
})

vim.api.nvim_create_user_command("Configs", function()
  --   local id = vim.fn["denops#callback#register"](function(s)
  --     -- vim.fn.execute(vim.fn.printf('echom "%s"', s), "")
  --     vim.fn.execute(vim.fn.printf(':e "%s"<CR>', s))
  --   end)
  --
  -- local paths = vim.fn.expand("~/.config/nvim/lua/configs/*.lua")
  -- local files = vim.fn.split(paths, "\n")
  --
  --   vim.fn["ddu#start"]({
  --     sources = {
  --       { name = "custom-list", params = {
  -- 	texts = files,
  --         callbackId = id,
  --       } },
  --     },
  --   })
end, { nargs = 0 })
