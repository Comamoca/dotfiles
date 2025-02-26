command! Ddt call s:create_new_terminal()<CR>

function s:create_new_terminal()
      " ターミナルのバッファを連番で管理する
      let g:ddt_terminal_id = get(g:, 'ddt_terminal_id', 0) + 1

      call ddt#start(#{
      \   name: t:->get('ddt_ui_terminal_last_name',
      \                 'terminal-' .. g:ddt_terminal_id),
      \   ui: 'terminal',
      \ })
endfunction

" nnoremap sD  <Cmd>call ddt#ui#terminal#kill_editor()<CR>

" nnoremap <C-t> <Cmd>Ddu -name=ddt -sync
"       \ -ui-param-ff-split=`has('nvim') ? 'floating' : 'horizontal'`
"       \ -ui-param-ff-winRow=1
"       \ -ui-param-ff-autoResize
"       \ -ui-param-ff-cursorPos=`tabpagenr()`
"       \ ddt_tab<CR>
" " }}}


call ddt#custom#patch_global(#{
      \   uiParams: #{
      \     terminal: #{
      \       nvimServer: '~/.cache/nvim/server.pipe',
      \       command: ['fish'],
      \       promptPattern: has('win32') ? '\f\+>' : '\w*% \?',
      \     },
      \   },
      \ })
