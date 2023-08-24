local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

--local keymap = vim.keymap
local keymap = vim.keymap.set

local runCmd = function(map, cmd)
	keymap("n", map, cmd .. "<CR>", opts)
end

local cr = "<CR>"
vim.g.mapleader = " "

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap("n", "s", "<C-w>", opts)
keymap("i", "jj", "<ESC>", opts)
keymap("n", "<S-k>", "{", opts)
keymap("n", "<S-j>", "}", opts)

keymap("t", "<ESC>", "<C-\\><C-n>", opts)

-- runCmd("<C-f>", ":Sayonara")

-- runCmd("<C-o>", ":Telescope find_files")
-- runCmd("<C-i>", ":Telescope buffers")
-- runCmd("<C-u>", ":Telescope commands")
-- runCmd("<C-g>", ":Telescope live_grep")

runCmd("<C-i>", ":Ddu buffer")
runCmd("<C-o>", ":Ddu file_rec")

runCmd("sp", ":split")
runCmd("sv", ":vs")

runCmd("<Leader>r", ":QuickRun")

runCmd("bn", ":bnext")
runCmd("bp", ":bprev")

runCmd("<ESC><ESC>", ":noh")

runCmd("<C-p>", ":call comfortable_motion#flick(-70)" .. cr)
runCmd("<C-n>", ":call comfortable_motion#flick(70)" .. cr)

runCmd("<C-t>", ":Deol -split=floating -winheight=20 -winwidth=80" .. cr)

if vim.g.neovide then
	keymap("n", "<C-c>", '"+y', opts)
	keymap("v", "<C-c>", '"+y', opts)

	keymap("n", "<C-v>", '"+p', opts)
	keymap("i", "<C-v>", "<C-r>+", opts)
	keymap("c", "<C-v>", "<C-r>+", opts)
	keymap("i", "<C-r>", "<C-v>", opts)
end

runCmd("<Leader>r", ":RunIt" .. cr)

runCmd("<C-u>", ":Fq" .. cr)

keymap("i", "<C-s>", "<C-o>:w" .. "<CR>", opts)
runCmd("<Leader>s", ":SymbolsOutline" .. cr)
runCmd("<Leader>f", ":Fern . -reveal=% -drawer -toggle -width=30" .. cr)
-- runCmd("", "" .. cr)
-- runCmd("", "" .. cr)

keymap("n", "<Leader><Leader>", ":FuzzyMotion" .. cr)
keymap("n", "<F4>", ":MundoToggle" .. cr)
keymap("n", "<Leader>t", ":lua require'mr-telescope'.mr()" .. cr)

-- vim.keymap.set("c", "<Leader>", "<Plug>(kensaku-search-replace)" .. cr)
vim.cmd("cnoremap <C-y> <Plug>(kensaku-search-replace)<CR>")
-- keymap("n", ":", ":FineCmdline" .. cr)
-- nnoremap : <cmd>FineCmdline<CR>
