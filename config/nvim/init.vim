call plug#begin()
"{{{

Plug 'sainnhe/gruvbox-material'
Plug 'tomasr/molokai'

Plug 'tpope/vim-commentary'

Plug 'kdheepak/lazygit.nvim'

Plug 'thinca/vim-quickrun'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'easymotion/vim-easymotion'

Plug 'vim-jp/vimdoc-ja'

Plug 'cohama/lexima.vim'

Plug 'nathanaelkane/vim-indent-guides'

Plug 'tpope/vim-surround'

Plug 'skanehira/translate.vim'

Plug 'matsui54/denops-popup-preview.vim'

Plug 'vim-denops/denops.vim'
Plug 'vim-denops/denops-helloworld.vim'


Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'previm/previm'



"}}}


" ddc.vim
" {{{

Plug 'Shougo/ddc.vim'
Plug 'vim-denops/denops.vim'

" Install your sources
Plug 'Shougo/ddc-around'
Plug 'Shougo/ddc-nvim-lsp'

 " Install your filters
Plug 'Shougo/ddc-matcher_head'
Plug 'Shougo/ddc-sorter_rank'
Plug 'matsui54/ddc-nvim-lsp-doc'

Plug 'Shougo/ddc-sorter_rank'
Plug 'LumaKernel/ddc-file'
Plug 'Shougo/ddc-nvim-lsp'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'hrsh7th/vim-vsnip'

"}}}

" ========================= ddc.vim End ====================================
"{{{
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" For vsnip users.
" Plug 'hrsh7th/cmp-vsnip'
" Plug 'hrsh7th/vim-vsnip'

" For luasnip users.
" Plug 'L3MON4D3/LuaSnip'
" Plug 'saadparwaiz1/cmp_luasnip'

" For ultisnips users.
Plug 'SirVer/ultisnips'
" Plug 'quangnguyen30192/cmp-nvim-ultisnips'

" For snippy users.
" Plug 'dcampos/nvim-snippy'
" Plug 'dcampos/cmp-snippy'}}}

Plug 'williamboman/nvim-lsp-installer'"{{{
Plug 'neovim/nvim-lspconfig'
Plug 'kabouzeid/nvim-lspinstall'"}}}



if has('nvim')"{{{
  Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/denite.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif"}}}


if has('nvim')"{{{
  Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/defx.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
"}}}


call plug#end()

" ======================== Vim-Pulg End =====================================}}}
" ======================== Plugin Settings Start ============================

" lazygit settings{{{
let g:lazygit_floating_window_winblend = 0 " transparency of floating window
let g:lazygit_floating_window_scaling_factor = 0.9 " scaling factor for floating window
let g:lazygit_floating_window_corner_chars = ['╭', '╮', '╰', '╯'] " customize lazygit popup window corner characters
let g:lazygit_floating_window_use_plenary = 0 " use plenary.nvim to manage floating window if available
let g:lazygit_use_neovim_remote = 1 " fallback to 0 if neovim-remote is not installed}}}

" setup mapping to call :LazyGit
nnoremap <silent> gg :LazyGit<CR>



" ======================== Builtin LS =======================================

"{{{

lua << EOF
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer

-- on_attach関数を使用して、次のキーのみをマップします
-- 言語サーバーが現在のバッファーに接続した後

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  -- <c-x> <c-o>によってトリガーされる完了を有効にします
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  --マッピング。
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  --以下の関数のドキュメントについては、 `：helpvim.lsp。*`を参照してください。

  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'L', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end

local lsp_installer = require("nvim-lsp-installer")
lsp_installer.on_server_ready(function(server)
    local opts = {}
    opts.on_attach = on_attach

    server:setup(opts)
    vim.cmd [[ do User LspAttachBuffers ]]
end)

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches

--ループを使用して、複数のサーバーで「setup」を便利に呼び出し、
--言語サーバーが接続するときのマップバッファーのローカルキーバインディング


   -- ◍ vuels
   -- ◍ pyright
   -- ◍ tsserver
   -- ◍ jedi_language_server
   -- ◍ cmake
   -- ◍ jsonls
   -- ◍ html
   -- ◍ gopls
   -- ◍ vimls
   -- ◍ pylsp
   -- ◍ cssls

local servers = {'pyright', 'rust_analyzer', 'tsserver' , 'vuels' , 'gopls', 'gopls'}

for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end
EOF


" ========================= ddc.vim =================================

" Customize global settings{{{
" Use around source.
" https://github.com/Shougo/ddc-around
call ddc#custom#patch_global('sources', ['around'])

" Use matcher_head and sorter_rank.
" https://github.com/Shougo/ddc-matcher_head
" https://github.com/Shougo/ddc-sorter_rank
call ddc#custom#patch_global('sourceOptions', {
      \ '_': {
      \   'matchers': ['matcher_head'],
      \   'sorters': ['sorter_rank']},
      \ })

" Change source options
call ddc#custom#patch_global('sourceOptions', {
      \ 'around': {'mark': 'A'},
      \ })
call ddc#custom#patch_global('sourceParams', {
      \ 'around': {'maxSize': 500},
      \ })

" Customize settings on a filetype
call ddc#custom#patch_filetype(['c', 'cpp'], 'sources', ['around', 'clangd'])
call ddc#custom#patch_filetype(['c', 'cpp'], 'sourceOptions', {
      \ 'clangd': {'mark': 'C'},
      \ })
call ddc#custom#patch_filetype('markdown', 'sourceParams', {
      \ 'around': {'maxSize': 100},
      \ })

" Mappings

" <TAB>: completion.
inoremap <silent><expr> <TAB>
\ pumvisible() ? '<C-n>' :
\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
\ '<TAB>' : ddc#map#manual_complete()


" <S-TAB>: completion back.
inoremap <expr><S-TAB>  pumvisible() ? '<C-p>' : '<C-h>'

" Use ddc.
call ddc#enable()


call ddc#custom#patch_global('sources', ['nvim-lsp'])
call ddc#custom#patch_global('sourceOptions', {
      \ '_': { 'matchers': ['matcher_head'] },
      \ 'nvim-lsp': {
      \   'mark': 'lsp',
      \   'forceCompletionPattern': '\.\w*|:\w*|->\w*' },
      \ })

" Use Customized labels
call ddc#custom#patch_global('sourceParams', {
      \ 'nvim-lsp': { 'kindLabels': { 'Class': 'c' } },
      \ })

" Base settings}}}

" nvim lsp {{{
call ddc_nvim_lsp_doc#enable()


call ddc#custom#patch_global('sources', ['nvim-lsp'])
call ddc#custom#patch_global('sourceOptions', {
      \ '_': { 'matchers': ['matcher_head'] },
      \ 'nvim-lsp': {
      \   'mark': 'lsp',
      \   'forceCompletionPattern': '\.\w*|:\w*|->\w*' },
      \ })

" Use Customized labels
call ddc#custom#patch_global('sourceParams', {
      \ 'nvim-lsp': { 'kindLabels': { 'Class': 'c' } },
      \ })






call popup_preview#enable()
call popup_preview#enable()"}}}

" set completeopt=menu,menuone,noselect

lua << EOF
   -- Setup nvim-cmp.
   local cmp = require'cmp'

   cmp.setup({
     snippet = {
       -- REQUIRED - you must specify a snippet engine
       expand = function(args)
         vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
         -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
         -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
         -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
       end,
     },
     mapping = {
       ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
       ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
       ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
       ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
       ['<C-e>'] = cmp.mapping({
         i = cmp.mapping.abort(),
         c = cmp.mapping.close(),
       }),
       ['<CR>'] = cmp.mapping.confirm({ select = true }),
     },
     sources = cmp.config.sources({
       { name = 'nvim_lsp' },
       { name = 'vsnip' }, -- For vsnip users.
       -- { name = 'luasnip' }, -- For luasnip users.
       -- { name = 'ultisnips' }, -- For ultisnips users.
       -- { name = 'snippy' }, -- For snippy users.
     }, {
       { name = 'buffer' },
     })
   })

   -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
   cmp.setup.cmdline('/', {
     sources = {
       { name = 'buffer' }
     }
   })

   -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
   cmp.setup.cmdline(':', {
     sources = cmp.config.sources({
       { name = 'path' }
     }, {
       { name = 'cmdline' }
     })
   })

EOF
"}}}


" Define mappings{{{
autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> d
  \ denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p
  \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> q
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> i
  \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <Space>
  \ denite#do_map('toggle_select').'j'
endfunction
"}}}


" Vim MarkDown{{{
let g:vim_markdown_folding_disabled = 1
let g:previm_enable_realtime = 1
let g:previm_open_cmd = 'microsoft-edge-dev'
"}}}

" ======================== Plugin Settings End ==============================

"if &compatible"{{{
"  set nocompatible               " Be iMproved
"endif
"
"" Required:
"set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim
"
"" Required:
"call dein#begin('~/.cache/dein')
"
"
"" Required:
"call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')
"
"" Add or remove your plugins here like this:
""call dein#add('Shougo/neosnippet.vim')
""call dein#add('Shougo/neosnippet-snippets')
"
"call dein#load_toml('~/.config/nvim/dein.toml', {'lazy': 0})
"call dein#load_toml('~/.config/nvim/dein_lazy.toml', {'lazy': 1})
"
"" Required:
"call dein#end()
"call dein#save_state()
"
"" Required:
"filetype plugin indent on
"syntax enable
"
"" If you want to install not installed plugins on startup.
"if dein#check_install()
"  call dein#install()
"endif
"
""End dein Scripts-------------------------
"}}}

let g:dein#auto_recache = 1

" === Coc Plugins ==={{{
" coc-jedi
" coc-vimlsp
" coc-json
" coc-tsserver

" === Fren.vim 操作方法 ===
" コマンド 	動作
" l 	フォルダを開く
" h 	フォルダを閉じる
" Return 	フォルダに潜る
" Ctr-h 	フォルダを1階層上に戻る
" o 	ファイル若しくはフォルダを開く
" ? 	コマンドのヘルプを開く
"
" === Vimspector 使い方 ===
" vimspector#Continue()

" <Plug>VimspectorContinue
" デバッグ中であれば、続きを実行。
" デバッグ中でなければ、デバッグを開始。
" vimspector#Stop()

" <Plug>VimspectorStop
" デバッグを停止
" vimspector#Restart()

" <Plug>VimspectorRestart
" 同じ設定で再実行
" vimspector#Pause()

" <Plug>VimspectorPause
" デバッグを一時停止
" vimspector#ToggleBreakpoint()

" <Plug>VimspectorToggleBreakpoint
" ブレークポイントを設定
" vimspector#StepOver()

" <Plug>VimspectorStepOver
" 次のステップ実行。（関数内部入らない）
" vimspector#StepInto()

" <Plug>VimspectorStepInto
" 次のステップ実行。（関数内部にも入る）
" vimspector#StepOut()

" <Plug>VimspectorStepOut
" 現在実行している、関数から抜けるまで実行。
" vimspector#Reset()

" :VimspectorReset
" デバッガーを完全に止める。}}}

set wildmenu 
set wildmode=full 
let g:vimsyn_embed='lPr'
set runtimepath+=$HOME/.config/nvim/scripts/
set runtimepath+=$HOME/ablaze/ablaze.vim

let mapleader = ","
nnoremap <leader> t :echo "You pushe leader t!
" let mapleader = "<,>"


" Neovimの設定

nnoremap <S-j> Nop
nnoremap <J> Nop
syntax enable

command Lazy :e ~/.config/nvim/dein_lazy.toml
command Source source $MYVIMRC" タブ切替

nnoremap <silent> <C-f> :bd<CR>

" ハイライトを有効にする
syntax enable
" colorscheme tokyonight
colorscheme gruvbox-material
let g:seiya_auto_enable=1

let g:python_host_prog = expand('~/nvim-python2/bin/python2')
let g:python3_host_prog = expand('/usr/bin/python3')

augroup TransparentBG
  	autocmd!
	autocmd colorscheme * highlight Normal ctermbg=none
	autocmd colorscheme * highlight NonText ctermbg=none
	autocmd colorscheme * highlight LineNr ctermbg=none
	autocmd colorscheme * highlight Folded ctermbg=none
	autocmd colorscheme * highlight EndOfBuffer ctermbg=none 
augroup END

" NERDTreeの設定
" autocmd vimenter * NERDTree" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" 隠しファイルを表示する
" let NERDTreeShowHidden = 1
" let NERDTreeShowHidden = 0
"
" " デフォルトでツリーを表示させる
" let g:nerdtree_tabs_open_on_console_startup=1
"
" " 他のバッファをすべて閉じた時にNERDTreeが開いていたらNERDTreeも一緒に閉じる。
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"
" map <silent> <C-e> :NERDTreeToggle<CR>


"easymoationの設定
" s{char}{char} to move to {char}{char}
map <Leader> <Plug>(easymotion-prefix)
let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
" nmap s <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
nmap s <Plug>(easymotion-overwin-f2)

" Turn on case insensitive feature
let g:EasyMotion_martcase = 1

" JK motions: Line motions
" map <Leader>j <Plug>(easymotion-j)
" map <Leader>k <Plug>(easymotion-k)

" Move to line
map <Leader>l <Plug>(easymotion-bd-jk)
nmap <Leader>l <Plug>(easymotion-overwin-line)

" HomeとEndをShiftとhlで代用
noremap <S-l>   $
noremap <S-h>   ^

" セミコロンでもコマンド入力ができるようにする
noremap ; :

nnoremap <Leader> m <C-w><C-w>
nnoremap <Leader> q :q<CR>
nnoremap <Leader> w :w<CR>

"行頭へ移動
inoremap <C-a> <C-o>^
"行末へ移動
inoremap <C-s> <C-o>$

nnoremap <C-a> ^
nnoremap <C-s> $

" C-xにBSの役割を割り当てる
inoremap <C-x> :<BS>


" キーの移動をわかりやすくする
noremap j  gj
noremap k  gk

" TABで候補を選択できるようにする
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" 補完表示時のEnterで改行をしない
inoremap <expr><CR>  pumvisible() ? "<C-y>" : "<CR>"
set completeopt=menuone

" Vimで日本語を書きやすくする
nnoremap あ a
nnoremap い i
nnoremap う u
nnoremap お o
nnoremap っd dd
nnoremap っy yy

" jjでエスケープ
inoremap <silent> jj <ESC>:w<CR>


" 日本語入力で”っj”と入力してもEnterキーで確定させればインサートモードを抜ける
inoremap <silent> っj <ESC>

noremap <Leader> g :Unite
nnoremap <c-g> <c-g>  :Unite 

command FishConfig e ~/.config/fish/config.fish


"行番号表示
set number
set spell

nnoremap <c-x> <Del>
inoremap <c-x> <Del>
nnoremap <c-/> :Commentary <CR> 

nnoremap <silent><Leader>f !black %:p

command Config e ~/.config/nvim/init.vim
command Plugins e ~/.config/nvim/dein.toml
command Scripts e  ~/.config/nvim/cmds.vim

" 自動保存の有効化
" let g:auto_save = 1

" nmap <silent> gd <Plug>(coc-definition)
" nmap <silent> gy <Plug>(coc-type-definition)
" nmap <silent> gi <Plug>(coc-implementation)
" nmap <silent> gr <Plug>(coc-references)
" nnoremap <silent> K :call <SID>show_documentation()<CR>
"
" function! s:show_documentation()
"   if (index(['vim','help'], &filetype) >= 0)
"     execute 'h '.expand('<cword>')
"   else
"     call CocAction('doHover')
"   endif
" endfunction

" Vim-lspの設定

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> <C-]> <plug>(lsp-definition)
  nmap <buffer> <f2> <plug>(lsp-rename)
  nmap <buffer> <Leader>d <plug>(lsp-type-definition)
  nmap <buffer> <Leader>r <plug>(lsp-references)
  nmap <buffer> <Leader>i <plug>(lsp-implementation)
  inoremap <expr> <cr> pumvisible() ? "\<c-y>\<cr>" : "\<cr>"
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
command! LspDebug let lsp_log_verbose=1 | let lsp_log_file = expand('~/lsp.log')

let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
" let g:asyncomplete_auto_popup = 1
" let g:asyncomplete_auto_completeopt = 0
let g:asyncomplete_popup_delay = 200
let g:lsp_text_edit_enabled = 1
let g:lsp_preview_float = 1
let g:lsp_diagnostics_float_cursor = 1
let g:lsp_settings_filetype_go = ['gopls', 'golangci-lint-langserver']

let g:lsp_settings = {}
let g:lsp_settings['gopls'] = {
  \  'workspace_config': {
  \    'usePlaceholders': v:true,
  \    'analyses': {
  \      'fillstruct': v:true,
  \    },
  \  },
  \  'initialization_options': {
  \    'usePlaceholders': v:true,
  \    'analyses': {
  \      'fillstruct': v:true,
  \    },
  \  },
  \}

" For snippets
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

set completeopt+=menuone


" 怒涛のお気に入り設定{{{
syntax on
set number
set expandtab
set hlsearch
set ignorecase
set incsearch
set smartcase
set autoindent
filetype plugin indent on
set wildmenu"}}}

" フォーマッタの実行
command! Black :!black %

nnoremap <silent> <C-i> :Unite b-auto-preview uffer<CR>

" denite
"  <C-o> open Denite-file-buffer-list
"    <Esc>      close Denite-file-buffer-list
"    <Space>    select multiple files/buffers
"    <CR>       open files/buffers
"    o          open files/buffers
"    s          open files/buffers in split windows (horizonal)
"    v          open files/buffers in split windows (vertical)
"    i          filter by string
"    ..         move to directory above


nnoremap <C-e> :Defx -split=vertical -winwidth=30 -columns=icons:indent:filename:type <CR>

autocmd FileType defx call s:defx_my_settings()

function! s:defx_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
   \ defx#do_action('drop')
  nnoremap <silent><buffer><expr> c
  \ defx#do_action('copy')
  nnoremap <silent><buffer><expr> m
  \ defx#do_action('move')
  nnoremap <silent><buffer><expr> p
  \ defx#do_action('paste')
  nnoremap <silent><buffer><expr> l
  \ defx#do_action('drop')
  nnoremap <silent><buffer><expr> <CR>
  \ defx#do_action('open','tabnew')
  nnoremap <silent><buffer><expr> E
  \ defx#do_action('drop', 'vsplit')
  nnoremap <silent><buffer><expr> P
  \ defx#do_action('drop', 'pedit')
  nnoremap <silent><buffer><expr> o
  \ defx#do_action('open_or_close_tree')
  nnoremap <silent><buffer><expr> K
  \ defx#do_action('new_directory')
  nnoremap <silent><buffer><expr> N
  \ defx#do_action('new_file')
  nnoremap <silent><buffer><expr> M
  \ defx#do_action('new_multiple_files')
  nnoremap <silent><buffer><expr> C
  \ defx#do_action('toggle_columns',
  \                'mark:indent:icon:filename:type:size:time')
  nnoremap <silent><buffer><expr> S
  \ defx#do_action('toggle_sort', 'time')
  nnoremap <silent><buffer><expr> d
  \ defx#do_action('remove')
  nnoremap <silent><buffer><expr> r
  \ defx#do_action('rename')
  nnoremap <silent><buffer><expr> !
  \ defx#do_action('execute_command')
  nnoremap <silent><buffer><expr> x
  \ defx#do_action('execute_system')
  nnoremap <silent><buffer><expr> yy
  \ defx#do_action('yank_path')
  nnoremap <silent><buffer><expr> .
  \ defx#do_action('toggle_ignored_files')
  nnoremap <silent><buffer><expr> ;
  \ defx#do_action('repeat')
  nnoremap <silent><buffer><expr> h
  \ defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> ~
  \ defx#do_action('cd')
  nnoremap <silent><buffer><expr> <C-e>
  \ defx#do_action('quit')
  nnoremap <silent><buffer><expr> q
  \ defx#do_action('quit')
  nnoremap <silent><buffer><expr> <Space>
  \ defx#do_action('toggle_select') . 'j'
  nnoremap <silent><buffer><expr> *
  \ defx#do_action('toggle_select_all')
  nnoremap <silent><buffer><expr> j
  \ line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent><buffer><expr> k
  \ line('.') == 1 ? 'G' : 'k'
  nnoremap <silent><buffer><expr> <C-l>
  \ defx#do_action('redraw')
  nnoremap <silent><buffer><expr> <C-g>
  \ defx#do_action('print')
  nnoremap <silent><buffer><expr> cd
  \ defx#do_action('change_vim_cwd')
endfunction




" set foldtext=FoldCCtext()
" set foldcolumn=1
" set fillchars=vert:\|


noremap <A-j> zj"{{{
noremap <A-k> zk
noremap <A-n> ]z
noremap <A-p> [z
noremap <A-c> zc
noremap <A-o> zo
noremap <A-a> za
noremap <A-m> zM
noremap <A-i> zMzv
noremap <A-R> zR
noremap <A-f> zf"}}}
nnoremap <silent> <C-o> :<C-u>Denite -auto-resize buffer file:new<CR>"{{{
autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
	      " Quit
        nnoremap <silent><buffer><expr> <Esc>
                \ denite#do_map('quit')

        nnoremap <silent><buffer><expr> <Space>
                \ denite#do_map('toggle_select').'j'

				" Default Open
        nnoremap <silent><buffer><expr> <CR>
                \ denite#do_map('do_action')


        nnoremap <silent><buffer><expr> o
                \ denite#do_map('do_action')

				" Open Split
        nnoremap <silent><buffer><expr> s
                \ denite#do_map('do_action', 'split')

        " Open Split
        nnoremap <silent><buffer><expr> v
                \ denite#do_map('do_action', 'vsplit')

				" Serch source
        nnoremap <silent><buffer><expr> i
                \ denite#do_map('open_filter_buffer')

        nnoremap <silent><buffer><expr> ..
                \ denite#do_map('move_up_path')

endfunction"}}}

"インサートモード時にカーソル移動する{{{
imap <c-h> <Left>
imap <c-j> <Down>
imap <c-k> <Up>
imap <c-l> <Right>

nnoremap <Esc> <Esc> :noh<CR>
au FileType vim setlocal foldmethod=marker

nnoremap <Space>a za"{{{
nnoremap <Space>f zf
nnoremap <Space>d zd
nnoremap <Space>R zR
nnoremap <Space>M zM"}}}

inoremap <C-h> <BS>
" nnoremap <silent> <C-e> :Fern . -reveal=% -drawer -toggle -width=25<CR>

" ターミナルモードの設定
tnoremap <Esc> <C-\><C-n>
command! -nargs=* T split | wincmd j | resize 5 | terminal <args>
autocmd TermOpen * startinsert

set hidden
" set pumblend=3

" セッションを保存
au VimLeave * mks! ~/.Session.vim

command Holodule :!python ~/holo-schedule-CLI/main.py
nnoremap <silent> <c-k> :bprev<CR>
nnoremap <silent> <c-j> :bnext<CR>

nnoremap K <Nop>
" Shiftで空行に移動
noremap <S-j>   }
noremap <S-k>   {


set nospell
command TmuxHelp e ~/tmux_help.txts
