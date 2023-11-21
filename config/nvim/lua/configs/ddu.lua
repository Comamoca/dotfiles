local filename = debug.getinfo(1).source:match("[^/]*$")
print(string.format("[[WARN]] @%s loading outside config file.", filename))
---

local keymap = vim.keymap.set

local ddu_custom_patch_global = vim.fn["ddu#custom#patch_global"]
-- local ddu_ui_ff_do_action = vim.fn["ddu#ui#ff#do_action"]
-- local ddu_item_action = vim.fn["ddu#item_action"]
-- local ddu_ui_ff_execute = vim.fn["ddu#ui#ff#execute"]

local keymap_opt = { buffer = true, silent = true }

local columns = vim.opt.columns:get()
local width, col = math.floor(columns * 0.8), math.floor(columns * 0.12)

ddu_custom_patch_global({
  ui = "ff",
  sources = {
    {
      -- default source
      name = "file_rec",
      params = {
        ignoredDirectories = { ".git", "node_modules", "vendor", ".next"},
      },
    },
  },
  sourceOptions = {
    _ = {
      matchers = { "matcher_substring" },
    },
  },
  filterParams = {
    matcher_substring = {
      highlightMatched = "Title",
    },
  },
  kindOptions = {
    file = {
      defaultAction = "open",
    },
    buffer = {
      defaultAction = "open",
    },
  },
  uiParams = {
    ff = {
      startFilter = true,
      prompt = "* ",
      -- prompt = " ",
      split = "floating",
      previewFloating = true,
      previewSplit = "vertical",
      previewFloatingBorder = "single",
      previewWidth = math.floor(width / 3),
      previewHeight = col,
      -- highlights = {
      --   floating = "Normal",
      --   floatingBorder = "Normal",
      -- },
      autoAction = {
        name = "preview",
      },
    },
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "ddu-ff",
  callback = function()
    print("filetype ddu-ff")

    keymap("n", "<CR>", "<Cmd>call ddu#ui#ff#do_action('itemAction')<CR>", keymap_opt)

    -- nnoremap <buffer><silent> i
    --       \ <Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>
    -- nnoremap <buffer><silent> q
    --       \ <Cmd>call ddu#ui#ff#do_action('quit')<CR>
    -- nnoremap <buffer><silent> p
    --   \ <Cmd>call ddu#ui#ff#do_action('preview')<CR>

    keymap("n", "<Space>", "<Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>", keymap_opt)
    keymap("n", "i", "<Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>", keymap_opt)
    keymap("n", "i", "<Cmd>call ddu#ui#ff#do_action('quit')<CR>", keymap_opt)
    keymap("n", "q", "<Cmd>call ddu#ui#ff#do_action('quit')<CR>", keymap_opt)

    vim.api.nvim_create_autocmd("CursorMoved", {
      pattern = "*",
      callback = function()
        -- <Cmd>call ddu#ui#ff#do_action('quit')<CR>
        vim.fn["ddu#ui#ff#do_action"]("preview")
      end,
    })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "ddu-ff-filter",
  callback = function()
    print("filetype ddu-ff-filter")

    keymap("i", "<C-c>", "<Esc><Cmd>close<CR>", keymap_opt)
    keymap("i", "<CR>", "<Esc><Cmd>close<CR>", keymap_opt)
    keymap("n", "<CR>", "<Cmd>close<CR>", keymap_opt)
    keymap("n", "q", "<Cmd>close<CR>", keymap_opt)
  end,
})

vim.cmd([[
" function! s:ddu_my_settings() abort
"   nnoremap <buffer><silent> <CR>
"         \ <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
"   nnoremap <buffer><silent> <Space>
"         \ <Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>
"   nnoremap <buffer><silent> i
"         \ <Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>
"   nnoremap <buffer><silent> q
"         \ <Cmd>call ddu#ui#ff#do_action('quit')<CR>
"   nnoremap <buffer><silent> p
"     \ <Cmd>call ddu#ui#ff#do_action('preview')<CR>
" endfunction

" function! s:ddu_filter_my_settings() abort
"   inoremap <buffer><silent> <CR>
"   \ <Esc><Cmd>close<CR>
"   nnoremap <buffer><silent> <CR>
"   \ <Cmd>close<CR>
"   nnoremap <buffer><silent> q
"   \ <Cmd>close<CR>
" endfunction

" autocmd FileType ddu-ff-filter call s:ddu_filter_my_settings()
" autocmd FileType ddu-ff call s:ddu_my_settings()

" autocmd CursorMoved * call ddu#ui#ff#do_action('preview')
]])
