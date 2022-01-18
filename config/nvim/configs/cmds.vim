command Source :source $MYVIMRC
command Config :e $MYVIMRC
command EditPlugs :e ~/.config/nvim/dein.toml
command EditLazyPlugs :e ~/.config/nvim/dein_lazy.toml

command Configs :Defx ~/.config/nvim/configs/ -columns=git:mark:filename:type
" command! -nargs=1 Configs call OpenConfig(<f-args>)

" let confgs_path = "~/.config/nvim/configs/"

" function! OpenConfig(config)
"   echo a:config
"   :e confgs_path . a:config
" endfunction
