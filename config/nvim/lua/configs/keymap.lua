local opts = { silent = true }
local cr = "<CR>"

local keymap = vim.keymap.set
local runCmd = function(map, cmd)
  keymap("n", map, cmd .. "<CR>", opts)
end

vim.g.mapleader = " "

keymap("i", "jj", "<C-[><C-[>")
keymap("n", "<C-[><C-[>", ":noh<CR>")

keymap("n", "s", "<C-w>", opts)
keymap("i", "jj", "<ESC>", opts)
-- keymap("n", "<S-k>", "{", opts)
-- keymap("n", "<S-j>", "}", opts)

keymap("n", "<c-p>", "{", opts)
keymap("n", "<c-n>", "}", opts)

keymap("n", "<C-f>", "<cmd>Sayonara<CR>", opts)

keymap("n", "<leader>f", "<cmd>Fern . -reveal=% -drawer -toggle -width=23<CR>", opts)

-- comfortable moation
vim.g.comfortable_motion_no_default_key_mappings = 1

-- keymap('n', '<C-p>', function()
-- vim.fn["comfortable_motion#flick"](40)
-- end, opts)
-- keymap('n', '<C-p>', function()
-- vim.fn["comfortable_motion#flick"](-40)
-- end, opts)

runCmd("<C-k>", ":call comfortable_motion#flick(-70)" .. cr)
runCmd("<C-j>", ":call comfortable_motion#flick(70)" .. cr)

-- keymap("n", "<S-k>", "<C-u>", opts)
-- keymap("n", "<S-j>", "<C-d>", opts)


local function ddu_start(source)
  -- call ddu#start({'sources': [{'name': 'buffer'}]})
  return string.format("<Esc>:call ddu#start({'sources': [{'name': '%s'}]})<CR>", source)
end

keymap("n", "<C-o>", "<cmd>Ddu file_rec<CR>", opts)
keymap("n", "<C-i>", "<cmd>Ddu buffer<CR>", opts)

-- call ddu#start({'sources': [{'name': 'buffer'}]})
keymap("i", "<C-l>", ddu_start("line"), opts)

keymap("t", "<Esc>", [[<C-\><C-n>]])
