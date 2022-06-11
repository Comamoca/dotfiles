
set encoding=utf-8 

if &compatible
  set nocompatible
endif


"function! s:packager_init(packager) abort{{{
"  call a:packager.add('kristijanhusak/vim-packager', { 'type': 'opt' })"{{{
"  " call a:packager.add('junegunn/fzf', { 'do': './install --all && ln -s $(pwd) ~/.fzf'})
"  " call a:packager.add('junegunn/fzf.vim')
"  " call a:packager.add('vimwiki/vimwiki', { 'type': 'opt' })
"  " call a:packager.add('Shougo/deoplete.nvim')
"  " call a:packager.add('autozimu/LanguageClient-neovim', { 'do': 'bash install.sh' })
"  " call a:packager.add('morhetz/gruvbox')
"  " call a:packager.add('lewis6991/gitsigns.nvim', {'requires': 'nvim-lua/plenary.nvim'})
"  " call a:packager.add('haorenW1025/completion-nvim', {'requires': [
"  " \ ['nvim-treesitter/completion-treesitter', {'requires': 'nvim-treesitter/nvim-treesitter'}],
"  " \ {'name': 'steelsojka/completion-buffers', 'opts': {'type': 'opt'}},
"  " \ 'kristijanhusak/completion-tags',
"  " \ ]})
"  " call a:packager.add('hrsh7th/vim-vsnip-integ', {'requires': ['hrsh7th/vim-vsnip'] })
"  " call a:packager.local('~/my_vim_plugins/my_awesome_plugin')

"  "Provide full URL; useful if you want to clone from somewhere else than Github.
"  " call a:packager.add('https://my.other.public.git/tpope/vim-fugitive.git')

"  "Provide SSH-based URL; useful if you have write access to a repository and wish to push to it
"  " call a:packager.add('git@github.com:mygithubid/myrepo.git')

"  "Loaded only for specific filetypes on demand. Requires autocommands below.
"  " call a:packager.add('kristijanhusak/vim-js-file-import', { 'do': 'npm install', 'type': 'opt' })
"  " call a:packager.add('fatih/vim-go', { 'do': ':GoInstallBinaries', 'type': 'opt' })
"  " call a:packager.add('neoclide/coc.nvim', { 'do': function('InstallCoc') })
"  " call a:packager.add('sonph/onehalf', {'rtp': 'vim/'})}}}
 
"  call a:packager.add('twitvim/twitvim')
"  call a:packager.add('honza/vim-snippets')
"  call a:packager.add('neoclide/coc.nvim')
"  call a:packager.add('sainnhe/gruvbox-material')
"  call a:packager.add('miyakogi/seiya.vim')
"  call a:packager.add('cohama/lexima.vim')
"  call a:packager.add('tpope/vim-commentary')
"  call a:packager.add('tyru/eskk.vim')
"  call a:packager.add('kana/vim-smartword')
"  call a:packager.add('dag/vim-fish')
"  call a:packager.add('morhetz/gruvbox')
"  call a:packager.add('vim-jp/vimdoc-ja')
"  call a:packager.add('skanehira/translate.vim')
"  call a:packager.add('vim-airline/vim-airline-themes')
"  call a:packager.add('thinca/vim-quickrun')
"  call a:packager.add('vim-airline/vim-airline')
"  call a:packager.add('simeji/winresizer')
"  call a:packager.add('previm/previm')
"  call a:packager.add('tyru/open-browser.vim')
"  call a:packager.add('Shougo/denite.nvim')
"  call a:packager.add('Shougo/defx.nvim')
"  call a:packager.add('kristijanhusak/defx-git')
"  call a:packager.add('nvim-treesitter/nvim-treesitter')
"  call a:packager.add('iberianpig/tig-explorer.vim')
"  call a:packager.add('easymotion/vim-easymotion')
"  call a:packager.add('thinca/vim-splash')
"  call a:packager.add('subnut/nvim-ghost.nvim')
"  call a:packager.add('turbio/bracey.vim')
"  call a:packager.add('alvan/vim-closetag')
"  call a:packager.add('maxmellon/vim-jsx-pretty')
"  call a:packager.add('karoliskoncevicius/moonshine-vim')
"  call a:packager.add('nvim-telescope/telescope.nvim')
"  call a:packager.add('nvim-lua/plenary.nvim')
"  call a:packager.add('mopp/layoutplugin.vim')
"  call a:packager.add('SirVer/ultisnips')
"  call a:packager.add('vim-denops/denops.vim')
"  call a:packager.add('vim-denops/denops-helloworld.vim')
"  call a:packager.add('vim-denops/denops-helloworld.vim')

"  call a:packager.add('Shougo/ddu.vim')
"  call a:packager.add('Shougo/ddu-commands.vim')
"  call a:packager.add('Shougo/ddu-ui-ff')
"  call a:packager.add('Shougo/ddu-filter-matcher_substring')
"  call a:packager.add('Shougo/ddu-kind-file')
"  call a:packager.add('Shougo/ddu-source-file')
"  call a:packager.add('yuki-yano/ddu-filter-fzf')
"  call a:packager.add('Shougo/ddu-source-file_rec')                  

"  call a:packager.add('w0rp/ale')
"  call a:packager.add('dense-analysis/ale')
" " call a:packager.add('')
" " call a:packager.add('')
" " call a:packager.add('')
" " call a:packager.add('')
" " call a:packager.add('')
" "
" " call a:packager.local('/home/coma/moc.vim')
" " call a:packager.local('/home/coma/vim-show-weather')
" endfunction

"" packadd vim-packager
"call packager#setup(function('s:packager_init'))}}}

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/jetpack.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/jetpack.vim --create-dirs  https://raw.githubusercontent.com/tani/vim-jetpack/master/autoload/jetpack.vim'
  autocmd VimEnter * JetpackSync | source $MYVIMRC
endif

let g:jetpack#optimization = 1

call jetpack#begin()

" Jetpack Exsample{{{
" Jetpack 'junegunn/fzf.vim'
" Jetpack 'junegunn/fzf', { 'do': {-> fzf#install()} }
" Jetpack 'neoclide/coc.nvim', { 'branch': 'release' }
" Jetpack 'neoclide/coc.nvim', { 'branch': 'master', 'do': 'yarn install --frozen-lockfile' }
" Jetpack 'vlime/vlime', { 'rtp': 'vim' }
" Jetpack 'dracula/vim', { 'as': 'dracula' }
" Jetpack 'tpope/vim-fireplace', { 'for': 'clojure' }
"}}}

"{{{
" Jetpack  'onsails/lspkind.nvim'
" Jetpack  'neovim/nvim-lspconfig'
" Jetpack  'williamboman/nvim-lsp-installer'
" Jetpack  'hrsh7th/nvim-cmp'
" Jetpack  'hrsh7th/cmp-nvim-lsp'
" Jetpack  'hrsh7th/cmp-vsnip'
" Jetpack  'hrsh7th/cmp-buffer'}}}

" =========== Lsp Utils ===========
Jetpack  'SirVer/ultisnips'
" Jetpack  'honza/vim-snippets'
" Jetpack  'twitvim/twitvim'
Jetpack  'neoclide/coc.nvim', { 'branch': 'release' }
Jetpack  'integralist/vim-mypy'
"
" Jetpack  'prabirshrestha/vim-lsp'
" Jetpack  'mattn/vim-lsp-settings'
" Jetpack  'shun/ddc-vim-lsp'
" Jetpack  'hrsh7th/vim-vsnip'
" Jetpack  'hrsh7th/vim-vsnip-integ'

" Jetpack  'thomasfaingnaert/vim-lsp-snippets'
" Jetpack  'thomasfaingnaert/vim-lsp-ultisnips'
Jetpack  'dense-analysis/ale'
Jetpack  'scrooloose/syntastic'
Jetpack  'Shougo/deol.nvim'

" =========== colorscheme ===========
" Jetpack  'sainnhe/gruvbox-material'
Jetpack  'morhetz/gruvbox'
Jetpack  'sainnhe/everforest'
Jetpack  'folke/tokyonight.nvim'
Jetpack  'tckmn/hotdog.vim'
" Jetpack  'sainnhe/sonokai'
" Jetpack  'arcticicestudio/nord-vim'

" =========== Tools =========== 
Jetpack  'yuttie/comfortable-motion.vim'
Jetpack  'lewis6991/gitsigns.nvim'
Jetpack  'echasnovski/mini.nvim', { 'branch': 'stable' }
Jetpack  'tpope/vim-surround'
Jetpack  'miyakogi/seiya.vim'
" Jetpack  'jceb/vim-orgmode'
Jetpack  'itchyny/calendar.vim'
Jetpack  'bun913/min-todo.vim'
Jetpack  'cohama/lexima.vim'
" Jetpack  'tpope/vim-commentary'
" Jetpack  'qbbr/vim-twig'
Jetpack  'glench/vim-jinja2-syntax'
Jetpack  'baabelfish/nvim-nim'
" Jetpack  'puremourning/vimspector', {'do': './install_gadget.py --all --force-all'}
Jetpack  'p00f/nvim-ts-rainbow'
" Jetpack  'SkyLeach/pudb.vim'
Jetpack  'mattn/vim-molder'

" Jetpack  'vim-skk/skkeleton'
Jetpack  'vim-skk/eskk.vim'

Jetpack  'kana/vim-smartword'
Jetpack  'dag/vim-fish'
Jetpack  'vim-jp/vimdoc-ja'
Jetpack  'skanehira/translate.vim'
" Jetpack  'vim-airline/vim-airline-themes'
Jetpack  'thinca/vim-quickrun'
Jetpack  'statiolake/vim-quickrun-runner-nvimterm'
" Jetpack  'vim-airline/vim-airline'
" Jetpack  'itchyny/lightline.vim'
" Jetpack  'airblade/vim-gitgutter'
Jetpack  'simeji/winresizer'
" Jetpack  'previm/previm'
Jetpack  'tyru/open-browser.vim'
Jetpack  'Shougo/denite.nvim'
Jetpack  'Shougo/defx.nvim'
Jetpack  'kristijanhusak/defx-git'
Jetpack  'nvim-treesitter/nvim-treesitter'
" Jetpack  'iberianpig/tig-explorer.vim'
Jetpack  'easymotion/vim-easymotion'
" Jetpack  'thinca/vim-splash'
" Jetpack  'vimwiki/vimwiki'
" Jetpack  'subnut/nvim-ghost.nvim'
"
" Jetpack  'turbio/bracey.vim'
Jetpack  'alvan/vim-closetag'
Jetpack  'maxmellon/vim-jsx-pretty'
Jetpack  'Jetpackkaroliskoncevicius/moonshine-vim'
Jetpack  'nvim-telescope/telescope.nvim'
Jetpack  'nvim-lua/plenary.nvim'
Jetpack  'mopp/layoutplugin.vim'
" Jetpack  'kassio/neoterm'
Jetpack  'skanehira/vsession'
Jetpack  'hisaknown/nanomap.vim'
Jetpack  'prabirshrestha/async.vim'
Jetpack  'mattn/emmet-vim'
Jetpack  'vim-syntastic/syntastic'
" Jetpack  'pechorin/any-jump.vim'
Jetpack  'nathanaelkane/vim-indent-guides'
" Jetpack  'Shougo/deoppet.nvim'
" Jetpack  'github/copilot.vim'

" =========== MarkDown Support =========== 
Jetpack  'tpope/vim-markdown'
Jetpack  'skanehira/preview-markdown.vim'
Jetpack  'previm/previm'
Jetpack  'tyru/open-browser.vim'

" =========== Denops Plugins =========== 
Jetpack  'vim-denops/denops.vim'
Jetpack  'vim-denops/denops-helloworld.vim'

" =========== Denops Settings =========== 
let g:denops_server_addr = '127.0.0.1:32123'

" =========== ddu Plugins =========== 
Jetpack  'Shougo/ddu.vim'

" =========== ddu UI =========== 
Jetpack  'Shougo/ddu-ui-ff'
Jetpack  'Shougo/ddu-ui-ff'

" =========== ddu Filter =========== 
Jetpack  'yuki-yano/ddu-filter-fzf'

" =========== ddu Matcher =========== 
Jetpack  'Shougo/ddu-filter-matcher_substring'

" =========== ddu Source =========== 
Jetpack  'liquidz/ddu-source-custom-list'
Jetpack  'Shougo/ddu-source-file_rec'
Jetpack  'Shougo/ddu-source-file'
Jetpack  'shun/ddu-source-rg'
Jetpack  'shun/ddu-source-buffer'
Jetpack  'shun/ddu-source-rg'
Jetpack  'Shougo/ddu-source-line'

" =========== ddu Kind =========== 
Jetpack  'Shougo/ddu-kind-file'


Jetpack  'Shougo/ddu-commands.vim'

" =========== ddc Plugins =========== 
" Jetpack  'Shougo/ddc.vim'
" Jetpack  'Shougo/ddc-around'
" Jetpack  'Shougo/ddc-matcher_head'
" Jetpack  'Shougo/ddc-sorter_rank'
" Jetpack  'Shougo/ddc-converter_remove_overlap'

" Jetpack  'Shougo/ddc.vim'
" Jetpack  'Shougo/ddc-around'
" Jetpack  'Shougo/ddc-matcher_head'
" Jetpack  'Shougo/ddc-sorter_rank'
" " Jetpack  'shun/ddc-vim-lsp'
" Jetpack  'shun/ddu-source-buffer'
" Jetpack  'LumaKernel/ddc-file'
" Jetpack  'tani/ddc-path'
" Jetpack  'matsui54/ddc-ultisnips'


" ================= My Plugins =================
" Jetpack  'file:///home/coma/ghq/github.com/coma/deolrun'

call jetpack#end()


runtime! plugsetsl*.vim
runtime! configs/*.vim
runtime! plugs/*.vim

lua <<EOF
require'nvim-treesitter.configs'.setup {
    highlight = {
	enable = true,
	},
    rainbow = {
	enable = true,
	-- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
	extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
	max_file_lines = nil, -- Do not enable for files with more than n lines, int
	-- colors = {}, -- table of hex strings
	-- termcolors = {} -- table of colour name strings
	}
    }
EOF


"source ~/.config/nvim/configs/plugs.vim

" let splt = split(glob("~/.config/nvim/configs/*.vim"))

" for file in splt
" 	" echo "load " . file
" 	execute 'source' file
" endfor

" runtime! plugsetsl*.vim
runtime! configs/*.vim
" runtime! configs/*.lua

" source ./autoload/jetpack.vim

" autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')

" let s:config_path = expand("~/.config/nvim/configs")
"

" execute 'set runtimepath+=' . fnamemodify(s:config_path, ':p')
" runtime! expand("~/.config/nvim/configs/*.vim")



if exists('g:vscode')
	command! VSCode :echo "VSCode!"
endif

" let chk=getftype("/home/coma/.skk/SKK-JISYO.L")
" if chk == ""
"     call system('curl -fsSL https://gist.githubusercontent.com/Comamoca/59cd42f5688e8f5ccee293bcd80b43b5/raw/18e713b03d873991c1ad181347c8ba7b3d4ac124/dl_jisyo.sh | sh')
" endif


" 補完表示時のEnterで改行をしない
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
