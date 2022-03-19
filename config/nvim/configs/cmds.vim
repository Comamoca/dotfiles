command! Source :source $MYVIMRC
command! Config :e $MYVIMRC
command! Configs :call ddu#start({'sources': [{'name': 'file_rec', 'params': {'path': expand('~/.config/nvim/configs')}}]})
command! Configs :call ConfigsRec()
command! Plugins :e ~/.config/nvim/dein.toml
command! PluginLazy :e ~/.config/nvim/dein_lazy.toml
command! ConfigsDefx :Defx ~/.config/nvim/configs
command! Org :Defx ~/org
command! Todo :tabe ~/todo.md<CR>
command! -nargs=1 Q call QSearch((<f-args>))
command! Black :call Pyformat()

" augroup auto_black
" 	autocmd!
" 	autocmd bufWritePost *.py :call Pyformat()
" augroup END

function! QSearch(word)
	execute "vimgrep" a:word expand("%") "| cw"
endfunction


" augroup auto_style
"   autocmd!
"   " autocmd bufWritePost *.py :call Pyformat()
" augroup END

" command! -nargs=1 Configs call OpenConfig(<f-args>)

let s:confgs_path = "~/.config/nvim/configs/"

" function! OpenConfig(config)
"   echo a:config
"   :e confgs_path . a:config
" endfunction
function! ConfigsRec() abort
	let cwd = getcwd()
	execute "cd" s:confgs_path
	:Denite file/rec
	execute "cd" cwd
	" call ddu#start({'sources': [{'name': 'file_rec', 'params': {'path': expand('~/.config/nvim/configs')}}]})
endfunction

function! Pyformat() abort
	:!black %
endfunction
