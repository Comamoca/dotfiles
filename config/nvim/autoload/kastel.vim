" ファイルタイプごとの補完候補の定義自体は変更なし
autocmd Filetype vim let b:symbol_list = ['..=', '=>', '=~#', '!=?']
autocmd Filetype gleam let b:symbol_list = ['->', '|>', '<>', '<-', '_ ->']

" 補完候補を表示する関数
function! s:symbol_cmp() abort
  " 補完指定用のキー 順番は要検討
  let triggers = 'hjklnmfdsavcuiorew'->split('\zs')

  " b:symbol_listとtriggersを組み合わせて補完リストを構築
  " （都度mapするのは効率が悪いかも？）
  " :help complete-items も参照
  let comp_list = b:symbol_list->copy()
        \ ->map({i, v -> {'word': v, 'menu': get(triggers, i, '')}})

  " ↑ を使って補完発動
  call complete(col('.')-1, comp_list)

  " ここからautocmd追加
  augroup symbolselect
    autocmd!
    " 候補展開中にキーが押されたときにs:symbol_select()を実行
    autocmd KeyInputPre * call s:symbol_select()
    " ↑が永続しないようモード変更時にautocmdを削除
    autocmd ModeChanged * autocmd! symbolselect
  augroup END
endfunction

function! s:symbol_select() abort
  " 現在の補完のリストは以下の式で取得できる
  let items = complete_info(['items']).items

  " 候補リストのmenuと入力されたキー（v:char）を照合
  let idx = indexof(items, {_,v -> get(v, 'menu', '') ==# v:char})

  " menuと対応するキーが押されていたら…
  if idx >= 0
    " カーソル直前の`,`を削除
    let v:char = "\<bs>"
    " v:charには1文字しか入れられないのでwordの入力にはfeedkeysを使う
    call feedkeys(items[idx].word, 'ni')
  endif
endfunction

" 起動用のキーマップは変更なし
inoremap <expr> , exists('b:symbol_list')
      \ ? ',<cmd>call <sid>symbol_cmp()<cr>'
      \ : ','
