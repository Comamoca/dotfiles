set encoding=utf-8
set nocompatible

const s:dpp_base = '~/.cache/dpp_vim/'

const s:dpp_src = '~/.cache/dpp_vim/repos/github.com/Shougo/dpp.vim'
const s:denops_src = '~/.cache/dpp_vim/repos/github.com/vim-denops/denops.vim'

execute 'set runtimepath^=' .. s:dpp_src

execute 'set runtimepath^=' .. '~/.cache/dpp_vim/repos/github.com/Shougo/dpp.vim'
execute 'set runtimepath^=' .. '~/.cache/dpp_vim/repos/github.com/Shougo/dpp-protocol-git'
execute 'set runtimepath^=' .. '~/.cache/dpp_vim/repos/github.com/Shougo/dpp-ext-installer'
execute 'set runtimepath^=' .. '~/.cache/dpp_vim/repos/github.com/Shougo/dpp-ext-toml'
execute 'set runtimepath^=' .. '~/.cache/dpp_vim/repos/github.com/Shougo/dpp-ext-lazy'


if s:dpp_base->dpp#min#load_state()
  " NOTE: dpp#make_state() requires denops.vim
  execute 'set runtimepath^=' .. s:denops_src

  autocmd User DenopsReady
  \ echo "denops ready"

  autocmd User DenopsReady
  \ call dpp#make_state(s:dpp_base, '~/.vim/dpp.ts')

  autocmd BufWritePre *.ts,*.tsx call execute('LspDocumentFormatSync --server=efm-langserver')
endif

execute 'set runtimepath^=' .. s:denops_src

if has('syntax')
  syntax on
endif

filetype indent plugin on

command! DppInstall :call s:dpp_install('install')
command! DppUpdate :call s:dpp_install('update')
command! DppMakeState :call dpp#make_state(s:dpp_base, '~/.vim/dpp.ts')


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

set backspace=indent,eol,start
set hlsearch
set incsearch
set ignorecase
set laststatus=2
set noshowmode
set formatoptions-=r
set formatoptions-=o

set completeopt=menuone,noinsert

set autoindent
" set smartindent
" set cindent
" set smarttab
" set expandtab

const mapleader = " "

nnoremap <silent> <C-k> <C-u>
nnoremap <silent> <C-j> <C-d>

nnoremap <silent> <C-[> <cmd>nohlsearch<CR>

nnoremap <C-o> <cmd>Ddu file_rec<CR>
nnoremap <C-i> <cmd>Ddu buffer<CR>
nnoremap <C-u> <cmd>Ddu mr<CR>
" nnoremap <C-u> <cmd>Ddu source<CR>
nnoremap <Leader>l <cmd>call vimspector#Launch()<CR>

nnoremap <Leader>f <cmd>call ddu#start({"name": "filer", "searchPath": expand('%:p'),})<CR>

nnoremap <C-f> <cmd>close<CR>

" nnoremap <buffer> <C-p> <Cmd>call <SID>operator_partedit()<CR>
" nnoremap <C-o> <cmd>Ddu file_rec<CR>
" nnoremap <C-o> <cmd>Ddu file_rec<CR>
" nnoremap <C-o> <cmd>Ddu file_rec<CR>

" execute("set runtimepath^=" .. expand("~/ghq/github.com/coma/memos.vim"))

inoremap jj <C-[>
nnoremap s <C-w>

autocmd CmdwinEnter * call s:cmd_win_hook()
function! s:cmd_win_hook() abort
    nnoremap <buffer> q <Cmd>quit<CR>
    nnoremap <buffer> <C-c> <Cmd>quit<CR>
    inoremap <buffer> <C-c> <ESC><Cmd>quit<CR>
endfunction

" au BufNewFile,BufRead *.hy setf lisp

let g:lightline = {
      \ 'colorscheme': 'seoul256',
      \ 'active': {
      \   'left': [
      \     [ 'mode', 'paste' ],
      \     [ 'lsp_errors', 'lsp_warnings', 'lsp_ok' ],
      \   ],
      \   'right': [
      \     [ 'percent' ],
      \     [ 'fileformat', 'fileencoding', 'filetype', 'bufchar'],
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
      \ 'component_function': {
      \   'bufchar': 'Bufchar'
      \ }
      \ }

function Bufchar() abort
	return wordcount()['chars'] 
endfunction

" set runtimepath+=~/.ghq/github.com/Comamoca/vimskey

set clipboard=unnamedplus
set autoindent

autocmd BufRead,ColorScheme * highlight Normal ctermbg=none
autocmd BufRead *.lark set filetype=lark
autocmd BufRead *.rs let g:rustfmt_autosave = 0

set statusline=─
set fillchars+=stl:─,stlnc:─,vert:│,eob:\\x20
highlight! link StatusLine Comment
highlight! link StatusLineNC Comment
highlight! link VertSplit Comment

inoremap <C-l> <Plug>(denippet-expand)

" ddu custom finder
const exec = denops#callback#register(
    \ {s -> execute(printf('execute "%s"', s), '')},
    \ {'once': v:true})

const cd = denops#callback#register(
    \ {s -> execute(printf('cd "%s"', s), '')},
    \ {'once': v:true})

function s:dduCustom(items, callback)
	call ddu#start({'sources': [
		\  {'name': 'custom-list',
		\   'params': {'texts': a:items, 'callbackId': a:callback}}]})
endfunction

function s:openConfig() abort 
    const configs = map(
    \  split(glob("~/.vim/*"), "\n"),
    \  "substitute(v:val, printf('%s/.vim/', $HOME), '', 'g')")

    const configedit = denops#callback#register(
        \ {s -> execute(printf('e ~/.vim/%s', s), '')},
        \ {'once': v:true})
    
    call s:dduCustom(configs, configedit)
endfunction

command! Configs call s:openConfig()


" call s:dduCustom(['DppInstall', 'DppMakeState', 'DppUpdate'], exec)

" const ghq_root = system('ghq root')

" echo system("ghq list")
" 	\ ->split()
" 	\ ->map('"/home/coma/.ghq/" .. v:val')

execute 'set runtimepath^=' .. '~/.ghq/github.com/Comamoca/memos.vim'
execute 'set runtimepath^=' .. '~/.ghq/github.com/coma/ddu-kind-cd'
execute 'set runtimepath^=' .. '~/.ghq/github.com/coma/baibai.vim'

if has('vim_starting')
    let &t_SI .= "\e[6 q"
    let &t_EI .= "\e[2 q"
    let &t_SR .= "\e[4 q"
endif

" set background=dark
" colorscheme gruvbox-material
" colorscheme deep-space
" set background=dark
" set termguicolors

" set termguicolors
augroup TransparentBG
  	autocmd!
	autocmd Colorscheme * highlight Normal ctermbg=none
	autocmd Colorscheme * highlight NonText ctermbg=none
	autocmd Colorscheme * highlight LineNr ctermbg=none
	autocmd Colorscheme * highlight Folded ctermbg=none
	autocmd Colorscheme * highlight EndOfBuffer ctermbg=none 
augroup END

set wildmenu
set wildmode=full

let g:deepspace_italics=1

set runtimepath^=~/.ghq/github.com/Comamoca/denops.init/tmp
set runtimepath^=~/.ghq/github.com/coma/vim-spotify
set runtimepath^=~/.ghq/github.com/coma/vim-palette

" set termguicolors
