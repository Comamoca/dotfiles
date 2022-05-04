"dein Scripts-----------------------------{{{if &compatible
"  set nocompatible               " Be iMproved
"endif

"" Required:
"set runtimepath+=/home/coma/.cache/dein/repos/github.com/Shougo/dein.vim

"" Required:
"call dein#begin('/home/coma/.cache/dein')
"" Let dein manage dein
"" Required:
"call dein#add('/home/coma/.cache/dein/repos/github.com/Shougo/dein.vim')

"call dein#load_toml("~/.config/nvim/dein.toml",      {'lazy': 0})
"call dein#load_toml("~/.config/nvim/dein_lazy.toml", {'lazy': 1})

"" Add or remove your plugins here like this:
""call dein#add('Shougo/neosnippet.vim')
""call dein#add('Shougo/neosnippet-snippets')

"" call dein#add('skanehira/translate.vim')
"" call dein#add('sainnhe/gruvbox-material')
"" call dein#add('wsdjeg/dein-ui.vim')

"" Required:
"call dein#end()

"" Required:
"filetype plugin indent on
"syntax enable

"" If you want to install not installed plugins on startup.
"if dein#check_install()
"  call dein#install()
"endif

""End dein Scripts-------------------------}}}

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
Jetpack  'sainnhe/gruvbox-material'
Jetpack  'morhetz/gruvbox'
Jetpack  'sainnhe/everforest'
Jetpack  'folke/tokyonight.nvim'
Jetpack  'tckmn/hotdog.vim'
Jetpack  'sainnhe/sonokai'

" =========== Tools =========== 
Jetpack  'tpope/vim-surround'
Jetpack  'miyakogi/seiya.vim'
" Jetpack  'jceb/vim-orgmode'
Jetpack  'itchyny/calendar.vim'
Jetpack  'bun913/min-todo.vim'
Jetpack  'cohama/lexima.vim'
Jetpack  'tpope/vim-commentary'
Jetpack  'qbbr/vim-twig'
Jetpack  'glench/vim-jinja2-syntax'
Jetpack  'baabelfish/nvim-nim'

" Jetpack  'vim-skk/skkeleton'
Jetpack  'vim-skk/eskk.vim'

Jetpack  'kana/vim-smartword'
Jetpack  'dag/vim-fish'
Jetpack  'vim-jp/vimdoc-ja'
Jetpack  'skanehira/translate.vim'
Jetpack  'vim-airline/vim-airline-themes'
Jetpack  'thinca/vim-quickrun'
Jetpack  'vim-airline/vim-airline'
Jetpack  'simeji/winresizer'
Jetpack  'previm/previm'
Jetpack  'tyru/open-browser.vim'
Jetpack  'Shougo/denite.nvim'
Jetpack  'Shougo/defx.nvim'
Jetpack  'kristijanhusak/defx-git'
Jetpack  'nvim-treesitter/nvim-treesitter'
Jetpack  'iberianpig/tig-explorer.vim'
Jetpack  'easymotion/vim-easymotion'
Jetpack  'thinca/vim-splash'
Jetpack  'vimwiki/vimwiki'
" Jetpack  'subnut/nvim-ghost.nvim'
"
Jetpack  'turbio/bracey.vim'
Jetpack  'alvan/vim-closetag'
Jetpack  'maxmellon/vim-jsx-pretty'
Jetpack  'Jetpackkaroliskoncevicius/moonshine-vim'
Jetpack  'nvim-telescope/telescope.nvim'
Jetpack  'nvim-lua/plenary.nvim'
Jetpack  'mopp/layoutplugin.vim'
Jetpack  'kassio/neoterm'
Jetpack  'arcticicestudio/nord-vim'
Jetpack  'skanehira/vsession'
Jetpack  'hisaknown/nanomap.vim'
Jetpack  'prabirshrestha/async.vim'
Jetpack  'mattn/emmet-vim'
Jetpack  'vim-syntastic/syntastic'
" Jetpack  'Shougo/deoppet.nvim'
" Jetpack  'github/copilot.vim'

" =========== Denops Plugins =========== 
Jetpack  'vim-denops/denops.vim'
Jetpack  'vim-denops/denops-helloworld.vim'


" =========== ddu Plugins =========== 
Jetpack  'Shougo/ddu.vim'
Jetpack  'Shougo/ddu-ui-ff'
Jetpack  'Shougo/ddu-commands.vim'
Jetpack  'Shougo/ddu-source-file_rec'
Jetpack  'Shougo/ddu-kind-file'
Jetpack  'Shougo/ddu-source-file'
Jetpack  'shun/ddu-source-rg'
Jetpack  'yuki-yano/ddu-filter-fzf'
Jetpack  'liquidz/ddu-source-custom-list'
Jetpack  'shun/ddu-source-buffer'

Jetpack  'Shougo/ddc.vim'
Jetpack  'Shougo/ddc-around'
Jetpack  'Shougo/ddc-matcher_head'
Jetpack  'Shougo/ddc-sorter_rank'
Jetpack  'Shougo/ddc-converter_remove_overlap'

Jetpack  'Shougo/ddc.vim'
Jetpack  'Shougo/ddc-around'
Jetpack  'Shougo/ddc-matcher_head'
Jetpack  'Shougo/ddc-sorter_rank'
" Jetpack  'shun/ddc-vim-lsp'
Jetpack  'shun/ddu-source-buffer'
Jetpack  'LumaKernel/ddc-file'
Jetpack  'tani/ddc-path'
Jetpack  'matsui54/ddc-ultisnips'

call jetpack#end()

runtime! plugsetsl*.vim
runtime! configs/*.vim

lua <<EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
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
				autocmd BufRead * :syntax enable
				autocmd BufEnter *.nim  set ts=2
				autocmd BufEnter *.nim  syntax enable
				autocmd BufEnter * set foldmethod=marker
augroup END
colorscheme gruvbox-material
