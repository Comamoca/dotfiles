const s:dpp_base = '~/.cache/dpp_vim/'

" Set dpp source path (required)
" const s:dpp_src = '~/.cache/dpp_vim/repos/github.com/Shougo/dpp.vim'
const s:dpp_src = '~/.cache/dpp_vim/pre/dpp.vim'
" const s:denops_src = '~/.cache/dpp_vim/repos/github.com/vim-denops/denops.vim'
const s:denops_src = '~/.cache/dpp_vim/pre/denops.vim'

" Set dpp runtime path (required)
execute 'set runtimepath^=' .. s:dpp_src

" execute 'set runtimepath+=' .. "~/.cache/dpp_vim/repos/github.com/Shougo/dpp-ext-installer"
" execute 'set runtimepath+=' .. "~/.cache/dpp_vim/repos/github.com/Shougo/dpp-ext-lazy"
" execute 'set runtimepath+=' .. "~/.cache/dpp_vim/repos/github.com/Shougo/dpp-ext-toml"
" execute 'set runtimepath+=' .. "~/.cache/dpp_vim/repos/github.com/Shougo/dpp-protocol-git"

execute 'set runtimepath+=' .. "~/.cache/dpp_vim/pre/dpp-ext-installer"
execute 'set runtimepath+=' .. "~/.cache/dpp_vim/pre/dpp-ext-lazy"
execute 'set runtimepath+=' .. "~/.cache/dpp_vim/pre/dpp-ext-toml"
execute 'set runtimepath+=' .. "~/.cache/dpp_vim/pre/dpp-protocol-git"

if dpp#min#load_state(s:dpp_base)
  " NOTE: dpp#make_state() requires denops.vim
  execute 'set runtimepath^=' .. s:denops_src
  autocmd User DenopsReady
  \ call dpp#make_state(s:dpp_base, '~/.vim/dpp.ts')
endif

if has('syntax')
  syntax on
endif

command! DppInstall :call s:dpp_install('install')
command! DppUpdate :call s:dpp_install('update')

function! s:dpp_install(cmd) abort
	if denops#server#status() == "running"
		call dpp#async_ext_action('installer', a:cmd)
	else
		echo "denops is not started"
	endif

endfunction

command! -nargs=1 Ddu call s:ddu_command(<f-args>)
function! s:ddu_command(args) abort
  echo a:args
  call ddu#start(#{ sources: [#{ name: a:args }] })
endfunction

set clipboard=unnamedplus
set backspace=indent,eol,start
set hlsearch
set incsearch
set ignorecase
set laststatus=2
set noshowmode

set completeopt=menuone,noinsert

set autoindent
" set smartindent
" set cindent
" set smarttab
" set expandtab

const mapleader = " "

nnoremap <silent> <C-[> <cmd>set nohlsearch<CR>

let g:seiya_auto_enable=1


nnoremap <C-o> <cmd>Ddu file_rec<CR>
nnoremap <C-i> <cmd>Ddu buffer<CR>
nnoremap <Leader>f <cmd>call ddu#start({"name": "filer", "searchPath": expand('%:p'),})<CR>

" nnoremap <buffer> <C-p> <Cmd>call <SID>operator_partedit()<CR>
" nnoremap <C-o> <cmd>Ddu file_rec<CR>
" nnoremap <C-o> <cmd>Ddu file_rec<CR>
" nnoremap <C-o> <cmd>Ddu file_rec<CR>

execute("set runtimepath^=" .. expand("~/ghq/github.com/coma/memos.vim"))

inoremap jj <C-[>
nnoremap s <C-w>

autocmd CmdwinEnter * call s:cmd_win_hook()
function! s:cmd_win_hook() abort
    nnoremap <buffer> q <Cmd>quit<CR>
    nnoremap <buffer> <C-c> <Cmd>quit<CR>
    inoremap <buffer> <C-c> <ESC><Cmd>quit<CR>
endfunction

let g:lightline = {
      \ 'colorscheme': 'seoul256',
      \ 'active': {
      \   'left': [
      \     [ 'mode', 'paste' ],
      \     [ 'lsp_errors', 'lsp_warnings', 'lsp_ok' ],
      \   ],
      \   'right': [
      \     [ 'percent' ],
      \     [ 'fileformat', 'fileencoding', 'filetype'  ],
      \   ],
      \ },
      \ 'component_expand': {
      \   'lsp_warnings': 'LightlineLSPWarnings',
      \   'lsp_errors':   'LightlineLSPErrors',
      \   'lsp_ok':       'LightlineLSPOk',
      \ },
      \ 'component_type': {
      \   'lsp_warnings': 'warning',
      \   'lsp_errors':   'error',
      \   'lsp_ok':       'middle',
      \ },
    \ }
