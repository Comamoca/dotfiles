command! Source :source $MYVIMRC
command! Config :e $MYVIMRC
" command! Configs :call ddu#start({'sources': [{'name': 'file_rec', 'params': {'path': expand('~/.config/nvim/configs')}}]})
command! Configs :call ConfigsRec("~/.config/nvim/configs/")
" command! ConfigsLinux :call ConfigsRec("~/.config/", 'directory_rec')
command! ConfigsLinux :Defx ~/.config
command! Plugins :e ~/.config/nvim/dein.toml
command! PluginLazy :e ~/.config/nvim/dein_lazy.toml
command! ConfigsDefx :Defx ~/.config/nvim/configs
command! Org :Defx ~/org
command! Todo :tabe ~/todo.md<CR>
command! -nargs=1 Q call QSearch((<f-args>))
command! Black :call Pyformat()
command! NimLint :call RunNimlint()
command! Ranger :call Ranger()
command! Xmod :!xmodmap ~/.Xmodmap


augroup auto_black
	" autocmd!
	" autocmd bufWritePost *.py :call Pyformat()
	autocmd TermOpen * startinsert
augroup END

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
function! ConfigsRec(confgs_path, ...) abort
	let cwd = getcwd()
	execute "cd" expand(a:confgs_path)
	execute 'Denite' get(a:, 1, 'file/rec')
	" execute 'Telescope find_files'
	execute "cd" cwd
	" call ddu#start({'sources': [{'name': 'file_rec', 'params': {'path': expand('~/.config/nvim/configs')}}]})
endfunction

function! Pyformat() abort
	:!black %
endfunction


function! RunNimlint() abort
	:!nimlint -i=% -o=%
endfunction

function! FloatTerm() abort
	" 空のバッファを作る
	let buf = nvim_create_buf(v:false, v:true)
	" そのバッファを使って floating windows を開く
	call nvim_open_win(buf, v:true, {'relative': 'win', 'height': 20, 'width': 80, 'col': 40, 'row': 8})
	tnoremap <C-f> <C-\><C-n>:<C-u>bw!<CR>
terminal
endfunction

function! Ranger() abort
	:enew
	:term ranger
	tnoremap q 
endfunction
