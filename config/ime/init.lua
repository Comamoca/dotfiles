local jetpack_begin = vim.fn["jetpack#begin"]
local jetpack_end = vim.fn["jetpack#end"]

local add = vim.fn["jetpack#add"]

vim.cmd("packadd vim-jetpack")

jetpack_begin()
add("tani/vim-jetpack", { opt = 1 }) --bootstrap

-- denops.vim
add("vim-denops/denops.vim")

-- ddc.vim
add("Shougo/ddc.vim")
add("tani/ddc-fuzzy")
add("Shougo/ddc-ui-native")
add("gamoutatsumi/ddc-emoji")
add("m4xshen/autoclose.nvim")

-- skkeleton
add("vim-skk/skkeleton")
add("NI57721/skkeleton-azik-kanatable")

-- colorscheme
add("rebelot/kanagawa.nvim")

jetpack_end()

vim.keymap.set("i", "jj", "<C-[>")

-- kanagawa.nvim
require("kanagawa").setup({
  compile = true,
  undercurl = true,
  commentStyle = { italic = true },
  keywordStyle = { italic = true },
  statementStyle = { bold = true },
  transparent = true,
})

vim.cmd("colorscheme kanagawa-dragon")
vim.cmd("nnoremap <C-[><C-[> <cmd>noh<CR>")
vim.cmd("nnoremap sv <cmd>vs<CR>")
vim.cmd("nnoremap s <C-w>")
vim.cmd("set ignorecase")
vim.cmd("set termguicolors")
vim.keymap.set("n", "<C-f>", "<cmd>close<CR>", opts)

-- ddc.vim
require("ddc")

-- skkeleton
-- require("skkeleton")
vim.cmd("source ~/.config/ime/skkeleton.vim")
vim.opt.clipboard = "unnamedplus"

-- enable autoclose
require("autoclose").setup()
