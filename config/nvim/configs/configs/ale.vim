 let g:ale_linters = {
     \ 'python': [
     \   'mypy'
     \ ],
     \ }
  " テキスト変更時にlintを実行しない
 " let g:ale_lint_on_text_changed = 'never'
 " 読み込み時には実行しない
 " let g:ale_lint_on_enter = 0
 " insertモードから抜けたら実行する
 " let g:ale_lint_on_insert_leave = 1
