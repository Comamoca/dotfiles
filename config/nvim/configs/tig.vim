" tigを開く
nnoremap <Leader>t :TigOpenProjectRootDir<CR>

" 現在のファイルの履歴を見る
nnoremap <Leader>T :TigOpenCurrentFile<CR>

" パターンでtig grepする
nnoremap <Leader>g :TigGrep<CR>

" tig grepした内容を再呼び出しする
nnoremap <Leader>r :TigGrepResume<CR>

" 選択中のキーワードでtig grepする
vnoremap <Leader>g y:TigGrep<Space><C-R>"<CR>

" カーソル下のキーワードでtig grepする
nnoremap <Leader>cg :<C-u>:TigGrep<Space><C-R><C-W><CR>

" 現在のカーソル位置でtig blameする
nnoremap <Leader>b :TigBlame<CR>
