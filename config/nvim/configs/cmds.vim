command Source :source $MYVIMRC
command Config :e $MYVIMRC
command Configs :call ConfigsReq()
command Plugins :e ~/.config/nvim/dein.toml
command PluginLazy :e ~/.config/nvim/dein_lazy.toml

command ConfigsDefx :Defx ~/.config/nvim/configs

" command! -nargs=1 Configs call OpenConfig(<f-args>)

let s:confgs_path = "~/.config/nvim/configs/"

" function! OpenConfig(config)
"   echo a:config
"   :e confgs_path . a:config
" endfunction

function! ConfigsReq() abort
	" let cwd = getcwd()
	" execute "cd" s:confgs_path
	" :Denite file/rec
	" execute "cd" cwd
	call ddu#start({'sources': [{'name': 'file_rec', 'params': {'path': expand('~/.config/nvim/configs')}}]})
endfunction























