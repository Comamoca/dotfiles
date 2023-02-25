local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

--local keymap = vim.keymap
local keymap = vim.keymap.set

local runCmd = function(map, cmd)
	keymap("n", map, cmd .. "<CR>", opts)
end

local cr = "<CR>"

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap("i", "jj", "<ESC>", opts)
keymap("n", "<S-k>", "{", opts)
keymap("n", "<S-j>", "}", opts)

keymap("t", "<ESC>", "<C-\\><C-n>", opts)

runCmd("<C-f>", ":Sayonara")

-- runCmd("<C-o>", ":Telescope find_files")
-- runCmd("<C-i>", ":Telescope buffers")
-- runCmd("<C-u>", ":Telescope")
-- runCmd("<C-g>", ":Telescope live_grep")

runCmd("<C-o>", ":Ddu file_rec")
runCmd("<C-i>", ":Ddu buffer")

runCmd("sp", ":split")
runCmd("sv", ":vs")

runCmd("<Leader>r", ":QuickRun")

runCmd("bn", ":bnext")
runCmd("bp", ":bprev")

runCmd("<ESC><ESC>", ":noh")

runCmd("<C-p>", ":call comfortable_motion#flick(-70)" .. cr)
runCmd("<C-n>", ":call comfortable_motion#flick(70)" .. cr)
runCmd("<C-t>", ":Deol" .. cr)
