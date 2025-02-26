local opts = { silent = true }
local cr = "<CR>"

local keymap = vim.keymap.set
local runCmd = function(map, cmd)
  keymap("n", map, cmd .. "<CR>", opts)
end

keymap("n", "<C-[><C-[>", ":noh<CR>")
keymap("n", "<C-u>", "<cmd>Ddu source<CR>")

keymap("n", "s", "<C-w>", opts)
keymap("n", "sl", "<c-w>l", opts)
keymap("n", "sh", "<c-w>h", opts)

keymap("i", "jj", "<ESC>", opts)

keymap("i", "<C-g>", "<C-[><C-[>")

keymap("n", "q", "<C-[><C-[>")

-- keymap("n", "<S-k>", "{", opts)
-- keymap("n", "<S-j>", "}", opts)

keymap("n", "<c-p>", "{", opts)
keymap("n", "<c-n>", "}", opts)

-- keymap("n", "<C-f>", "<cmd>Sayonara<CR>", opts)
keymap("n", "<C-f>", "<cmd>close<CR>", opts)

keymap("n", "<leader>f", "<cmd>Fern . -reveal=% -drawer -toggle -width=23<CR>", opts)

keymap("n", "<M-x>", "")

-- for Emacs compativirity
keymap("n", "<C-g>", "<ESC>")

-- comfortable moation
vim.g.comfortable_motion_no_default_key_mappings = 1

-- keymap('n', '<C-p>', function()
-- vim.fn["comfortable_motion#flick"](40)
-- end, opts)
-- keymap('n', '<C-p>', function()
-- vim.fn["comfortable_motion#flick"](-40)
-- end, opts)

-- runCmd("<C-k>", ":call comfortable_motion#flick(-70)" .. cr)
-- runCmd("<C-j>", ":call comfortable_motion#flick(70)" .. cr)

-- keymap("n", "<C-u>", "nop")
-- keymap("n", "<C-d>", "nop")

keymap("n", "<C-k>", "<C-u>")
keymap("n", "<C-j>", "<C-d>")

-- keymap("n", "<S-k>", "<C-u>", opts)
-- keymap("n", "<S-j>", "<C-d>", opts)

local function ddu_start(source)
  -- call ddu#start({'sources': [{'name': 'buffer'}]})
  return string.format("<Esc>:call ddu#start({'sources': [{'name': '%s'}]})<CR>", source)
end

-- ddu keymap
keymap("n", "<C-o>", "<cmd>Ddu file_external<CR>", opts) -- file open
keymap("n", "<C-i>", "<cmd>Ddu buffer<CR>", opts) -- buffer ope
-- keymap("n", "<C-i>", function()
--   vim.cmd([[call ddu#start({'sources': [{'name': 'mr'}]})]])
-- end)
-- keymap("n", "<C-u>", "<cmd>Ddu source<CR>") -- search sources

-- call ddu#start({'sources': [{'name': 'buffer'}]})
keymap("n", "<C-l>", ddu_start("line"), opts)
keymap("n", "<leader>l", ddu_start("lsp_codeAction"), opts)

keymap("t", "<Esc>", [[<C-\><C-n>]])

vim.api.nvim_create_autocmd("FileType", {
  pattern = "help",
  callback = function(opts)
    vim.api.nvim_buf_set_keymap(0, "n", "gd", "<C-]>", { silent = true })
  end,
})

vim.fn.getwininfo()

vim.fn.filter(vim.fn.getwininfo(), function(key, val)
  return val.quickfix
end)
vim.print()

keymap("n", "q", function()
  if vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), "v:val.quickfix")) then
    vim.cmd("copen")
  else
    vim.cmd("cclose")
  end
end)
