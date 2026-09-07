local opts = { silent = true }

local keymap = vim.keymap.set

keymap("n", "<C-[><C-[>", ":noh<CR>")
keymap("n", "<C-u>", "<cmd>Ddu source<CR>")

keymap("n", "s", "<C-w>", opts)
keymap("n", "sl", "<c-w>l", opts)
keymap("n", "sh", "<c-w>h", opts)

keymap("i", "jj", "<ESC>", opts)

keymap("i", "<C-g>", "<C-[><C-[>")

keymap("n", "<c-p>", "{", opts)
keymap("n", "<c-n>", "}", opts)

keymap("n", "<C-f>", "<cmd>close<CR>", opts)

keymap("n", "<leader>f", "<cmd>Fern . -reveal=% -drawer -toggle -width=23<CR>", opts)
keymap("n", "<leader>t", "<cmd>ToggleTerm direction=float<CR>", opts)

keymap("n", "<M-x>", "")

-- for Emacs compativirity
keymap("n", "<C-g>", "<ESC>")

-- comfortable moation
vim.g.comfortable_motion_no_default_key_mappings = 1

keymap("n", "<C-k>", "<C-u>")
keymap("n", "<C-j>", "<C-d>")

local function ddu_start(source)
  return string.format("<Esc>:call ddu#start({'sources': [{'name': '%s'}]})<CR>", source)
end

-- ddu keymap
keymap("n", "<C-o>", "<cmd>Ddu file_external<CR>", opts) -- file open
-- Note: <C-i> == <Tab> in terminal, but we only use this in normal mode
keymap("n", "<C-i>", "<cmd>Ddu buffer<CR>", opts) -- buffer ope

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
