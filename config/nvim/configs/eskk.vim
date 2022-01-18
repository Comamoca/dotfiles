" imap <C-j> <Nop>

" autocmd VimEnter * imap <C-j> <Plug>(eskk:toggle)
" autocmd VimEnter * cmap <C-j> <Plug>(eskk:toggle)

let g:eskk#directory = "~/.config/eskk"
let g:eskk#dictionary = { 'path': "~/.config/eskk/my_jisyo", 'sorted': 1, 'encoding': 'utf-8',}
let g:eskk#large_dictionary = {'path': "~/.config/eskk/SKK-JISYO.L", 'sorted': 1, 'encoding': 'utf-8',}

imap <C-d> <Plug>(eskk:toggle)
cmap <C-d> <Plug>(eskk:toggle)


let g:eskk#kakutei_when_unique_candidate = 1 "漢字変換した時に候補が1つの場合、自動的に確定する
let g:eskk#enable_completion = 0             "neocompleteを入れないと、1にすると動作しなくなるため0推奨
let g:eskk#no_default_mappings = 1           "デフォルトのマッピングを削除
let g:eskk#keep_state = 0                    "ノーマルモードに戻るとeskkモードを初期値にする
let g:eskk#egg_like_newline = 1              "漢字変換を確定しても改行しない。

augroup vimrc_eskk
  autocmd!
  autocmd User eskk-enable-post lmap <buffer> l <Plug>(eskk:disable)
augroup END

imap jk <Plug>(eskk:toggle)
cmap jk <Plug>(eskk:toggle)

"表示文字を変更(オレ サンカクデ ハンダン デキナイ)
" let g:eskk#marker_henkan = "[変換]"
" let g:eskk#marker_henkan_select = "[選択]"
" let g:eskk#marker_okuri = "[送り]"
" let g:eskk#marker_jisyo_touroku = "[辞書]"
