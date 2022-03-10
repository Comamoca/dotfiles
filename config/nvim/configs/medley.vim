colorscheme gruvbox-material
set number
set noautoindent
set smartindent
set fileencodings=utf-8

au FileType vim setlocal foldmethod=marker
set foldmethod=marker

nnoremap <Space> <Nop>
let mapleader = "\<Space>"
let mapleader = "\<Space>"

if &term =~ 'tmux'
  let &t_EI .= "\ePtmux;\e\e[<0t\e\\"
elseif &term =~ 'xterm'
  let &t_EI .= "\e[<0t"
endif

if executable("rg")
    let &grepprg = 'rg --vimgrep --hidden > /dev/null'
    set grepformat=%f:%l:%c:%m
endif
