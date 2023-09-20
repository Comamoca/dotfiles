require("configs/ddu-kind")
local sugar = require("comatools/sugar")

local ddu_patch_global = sugar.ddu_patch_global
local imap = sugar.imap
local nmap = sugar.nmap

ddu_patch_global({
	ui = "ff",
	uiParams = {
		ff = {
			previewFloating = true,
			previewFloatingBorder = "single",
			split = "floating",
		},
	},
})

-- ddu_patch_global({
-- 	uiParams = {
-- 		filer = {
-- 			split = "floating",
-- 		},
-- 	},
-- })

-- ddu_patch_global({
-- 	ui = "filer",
-- 	sourceOptions = {
-- 		_ = {
-- 			-- columns = {'filename'},
-- 		},
-- 	},
-- 	kindOptions = {
-- 		file = {
-- 			defaultAction = "open",
-- 		},
-- 	},
-- })

-- call ddu#start({'sources': [
--     \  {'name': 'custom-list',
--     \   'params': {'texts': ['hello', 'world'], 'callbackId': id}}]})

-- キーマップでエラー。多分mapping絡み。頑張れ明日の自分
-- local nmap = function (map, cmd)
-- 	local opts = { noremap = true, silent = true }

-- 	vim.api.nvim_buf_set_keymap("n", map, cmd, opts)
-- end

-- local function ddu_keymap()
-- 		nmap("<CR>", "<Cmd>call ddu#ui#ff#do_action('itemAction', {'name': 'open', 'params': {'command': 'vsplit'}})<CR>")
-- 		nmap("i", "<Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>")
-- 		nmap("<Space>", "<Cmd>call ddu#ui#ff#do_action('itemAction', {'name': 'open', 'params': {'command': 'split'}})<CR>")
-- 		nmap("o", "<Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>")
-- 		nmap("p", "<Cmd>call ddu#ui#ff#do_action('preview')<CR>")
-- 		nmap("q", "<Cmd>call ddu#ui#ff#do_action('quit')<CR>")
-- 	end

-- vim.api.nvim_create_augroup( 'lua', {} )
-- vim.api.nvim_create_autocmd({"FileType"}, {
-- 	group = 'lua',
-- 	pattern = {"ddu-ff"},
-- 	callback = function ()
-- 		ddu_keymap()
-- 	end
-- })

vim.api.nvim_create_augroup("ddu", {})

function ddu_filter_my_settings(args)
	nmap("<CR>", "<Cmd>call ddu#ui#ff#do_action('itemAction')<CR>")
	nmap("q", "<Cmd>call ddu#ui#ff#do_action('quit')<CR>")
	nmap("<CR>", "<Cmd>call ddu#ui#ff#do_action('itemAction')<CR>")
	nmap("<C-j>", [[<Cmd>call ddu#ui#ff#execute("call cursor(line('.')+1,0)")<CR>]])
	nmap("<C-k>", [[<Cmd>call ddu#ui#ff#execute("call cursor(line('.')-1,0)")<CR>]])
end

function ddu_my_settings(args)
	imap("<CR>", [[<Cmd>call ddu#ui#ff#do_action('itemAction')<CR>]])
	imap("<C-j>", [[<Cmd>call ddu#ui#ff#execute("call cursor(line('.')+1,0)")<CR>]])
	imap("<C-k>", [[<Cmd>call ddu#ui#ff#execute("call cursor(line('.')-1,0)")<CR>]])
	nmap("i", "<Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>")
	nmap("q", "<Cmd>call ddu#ui#ff#do_action('quit')<CR>")
end

vim.cmd([[
function! s:ddu_ff_settings() abort
  nnoremap <buffer><silent> <CR>
        \ <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  nnoremap <buffer><silent> <Space>
        \ <Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>
  nnoremap <buffer><silent> i
        \ <Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>
  nnoremap <buffer><silent> q
        \ <Cmd>call ddu#ui#ff#do_action('quit')<CR>
  nnoremap <buffer><silent> p
        \ <Cmd>call ddu#ui#ff#do_action('preview')<CR>
endfunction

function! s:ddu_filter_my_settings() abort
  nnoremap <buffer> <CR>
  \ <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  inoremap <buffer> <CR>
  \ <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  inoremap <buffer> <C-j>
  \ <Cmd>call ddu#ui#ff#execute("call cursor(line('.')+1,0)")<CR>
  inoremap <buffer> <C-k>
  \ <Cmd>call ddu#ui#ff#execute("call cursor(line('.')-1,0)")<CR>
  nnoremap <buffer><silent> q
  \ <Cmd>call ddu#ui#ff#do_action('quit')<CR>
endfunction

function! s:ddu_filer_my_settings() abort
  nnoremap <buffer><silent> <CR>
        \ <Cmd>call ddu#ui#filer#do_action('itemAction')<CR>
  nnoremap <buffer><silent> <Space>
        \ <Cmd>call ddu#ui#filer#do_action('toggleSelectItem')<CR>
  nnoremap <buffer> o
        \ <Cmd>call ddu#ui#filer#do_action('expandItem',
        \ {'mode': 'toggle'})<CR>
  nnoremap <buffer><silent> q
        \ <Cmd>call ddu#ui#filer#do_action('quit')<CR>
endfunction

autocmd FileType ddu-ff-filter call s:ddu_filter_my_settings()
autocmd FileType ddu-ff call s:ddu_ff_settings()
autocmd FileType ddu-filer call s:ddu_filer_my_settings()
]])
