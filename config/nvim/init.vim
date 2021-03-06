" Skip initialzed
let g:did_install_default_menus = 1
let g:did_install_syntax_menu   = 1
let g:did_indent_on             = 1
let g:did_load_filetypes        = 1
let g:did_load_ftplugin         = 1
let g:loaded_2html_plugin       = 1
let g:loaded_gzip               = 1
let g:loaded_man                = 1
let g:loaded_matchit            = 1
let g:loaded_matchparen         = 1
let g:loaded_netrwPlugin        = 1
" let g:loaded_remote_plugins     = 1
let g:loaded_shada_plugin       = 1
let g:loaded_spellfile_plugin   = 1
let g:loaded_tarPlugin          = 1
let g:loaded_tutor_mode_plugin  = 1
let g:loaded_zipPlugin          = 1
let g:skip_loading_mswin        = 1

let g:configspath = expand('~/.config/nvim/configs')

" set runtimepath^=~/.config/nvim/plugin/jetpack.vim

" =========== Denops Settings =========== 
" let g:denops_server_addr = '127.0.0.1:32123'

" let dein = expand('~/.config/nvim/dein.vim')
" execute 'source ' . dein

" let jetpack = expand('~/.config/nvim/jetpack.vim')
" execute 'source' jetpack





"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=/home/coma/.cache/dein/repos/github.com/Shougo/dein.vim

" Required:
call dein#begin('/home/coma/.cache/dein')

" Let dein manage dein
" Required:
call dein#add('/home/coma/.cache/dein/repos/github.com/Shougo/dein.vim')

" Add or remove your plugins here like this:
"call dein#add('Shougo/neosnippet.vim')
"call dein#add('Shougo/neosnippet-snippets')

 call dein#load_toml('/home/coma/.config/nvim/dein.toml',      {'lazy': 0})
 call dein#load_toml('/home/coma/.config/nvim/dein_lazy.toml', {'lazy': 1})

" Required:
call dein#end()

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
"if dein#check_install()
"  call dein#install()
"endif

"End dein Scripts-------------------------






set encoding=utf-8 

if &compatible
  set nocompatible
endif

runtime! plugsetsl*.vim
runtime! configs/*.vim
runtime! plugs/*.vim

" lua <<EOF
" require'nvim-treesitter.configs'.setup {
"     highlight = {
"         enable = true,
"         },
"         rainbow = {
"             enable = true,
"             -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
"             extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
"             max_file_lines = nil, -- Do not enable for files with more than n lines, int
"             -- colors = {}, -- table of hex strings
"             -- termcolors = {} -- table of colour name strings
"         }
"     }
" EOF


"source ~/.config/nvim/configs/plugs.vim

" let splt = split(glob("~/.config/nvim/configs/*.vim"))

" for file in splt
" 	" echo "load " . file
" 	execute 'source' file
" endfor

" runtime! plugsetsl*.vim
"runtime! configs/*.vim
" runtime! configs/*.lua

" source ./autoload/jetpack.vim

" autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')

" let s:config_path = expand("~/.config/nvim/configs")
"

" execute 'set runtimepath+=' . fnamemodify(s:config_path, ':p')
" runtime! expand("~/.config/nvim/configs/*.vim")


" load local Plugins
set runtimepath^=~/denops.vim


if exists('g:vscode')
	command! VSCode :echo "VSCode!"
endif

" let chk=getftype("/home/coma/.skk/SKK-JISYO.L")
" if chk == ""
"     call system('curl -fsSL https://gist.githubusercontent.com/Comamoca/59cd42f5688e8f5ccee293bcd80b43b5/raw/18e713b03d873991c1ad181347c8ba7b3d4ac124/dl_jisyo.sh | sh')
" endif


" ??????????????????Enter?????????????????????
inoremap <expr><CR>  pumvisible() ? "<C-y>" : "<CR>"

set completeopt=menuone,noinsert
inoremap <expr><C-n> pumvisible() ? "<Down>" : "<C-n>"
inoremap <expr><C-p> pumvisible() ? "<Up>" : "<C-p>"

inoremap <expr><Tab> pumvisible() ? "<C-n>" : "<Tab>"

" set pumblend=30
" hi NormalFloat guifg=#2e3440 guibg=#a3be8c

augroup vimrc
	autocmd VimEnter * inoremap <expr><Tab> pumvisible() ? "<C-n>" : "<Tab>"
	" autocmd VimEnter * let g:indent_guides_enable_on_vim_startup = 0
	" autocmd BufRead,BufNewFile * let g:indent_guides_enable_on_vim_startup = 1
	" autocmd VimEnter * GitGutterDisable
	autocmd BufRead * :syntax enable
	autocmd BufRead,BufNewFile *.nim  set ts=2
	autocmd BufRead,BufNewFile *.nim  set shiftwidth=2
	autocmd BufRead,BufNewFile *.nim  syntax enable
	autocmd BufRead,BufNewFile *.nim  set filetype=nim

	autocmd BufRead,BufNewFile *.ts  set shiftwidth=2
	autocmd BufEnter * set foldmethod=marker

	autocmd BufRead, BufEnter *.vim imap <buffer> <CR> <Plug>(smart_back_slash_linefeed)
	autocmd BufRead, BufEnter *.vim imap <buffer> <C-CR> <Plug>(back_slash_linefeed)
	autocmd BufRead,BufNewFile *.vim  set shiftwidth=4
	autocmd BufRead,BufNewFile *.lua  set shiftwidth=2
	autocmd BufRead,BufNewFile *.nims  set shiftwidth=2
	autocmd BufRead,BufNewFile *.nim  set shiftwidth=2
	autocmd BufRead,BufNewFile *.qml  set filetype=qml
	" autocmd BufRead,BufNewFile *.html  set filetype=html
	" autocmd BufRead,BufNewFile *.html  set shiftwidth=2
augroup END
colorscheme gruvbox

set laststatus=2
set noshowmode

" function! LightlineUpdate()
" 	:Source
" 	:call lightline#toggle()
" endfunction

" nnoremap <C-q> :call LightlineUpdate()<CR>
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1

" g:vimspector_configurations = "$HOME/.config/nvim/vimspector.json"

let g:quickrun_config = {}
let g:quickrun_config._ = {}
if has('nvim')
    let g:quickrun_config._['runner'] = 'nvimterm'
endif

" let g:instant_markdown_autostart = 0

let g:previm_open_cmd = "firefox"

let g:comfortable_motion_no_default_key_mappings = 1
let g:comfortable_motion_impulse_multiplier = 1  " Feel free to increase/decrease this value.
nnoremap <silent> <C-j> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * 2)<CR>
nnoremap <silent> <C-k> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * -2)<CR>

set autoindent


set expandtab "??????????????????????????????????????????????????????
set tabstop=2 "???????????????????????????????????????
set shiftwidth=2 "????????????????????????????????????
set softtabstop=2 "???????????????????????????????????????????????????????????????????????????????????????????????????
set autoindent "??????????????????????????????????????????????????????
set smartindent "????????????????????????????????????????????????????????????????????????????????????????????????

" let g:denops_server_addr = '127.0.0.1:32123'
" call jobstart(
" \	'deno run -A --no-check ' . dein#get('denops.vim').path . '/denops/@denops-private/cli.ts',
" \	{'detach': v:true}
" \)

" call dein#update()
