" nnoremap <silent><C-o> :<C-u>Denite buffer -auto-action=preview_bat<CR>
" nnoremap <silent><C-p> :<C-u>Denite file/rec -auto-action=preview_bat<CR>

" Define mappings
autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> d
  \ denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p
  \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> q
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> i
  \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <Space>
  \ denite#do_map('toggle_select').'j'
endfunction

" Change denite default options

let s:denite_win_width_percent = 0.85
let s:denite_win_height_percent = 0.7

call denite#custom#option('default', {
    \ 'split': 'floating',
    \ 'winwidth': float2nr(&columns * s:denite_win_width_percent),
    \ 'wincol': float2nr((&columns - (&columns * s:denite_win_width_percent)) / 2),
    \ 'winheight': float2nr(&lines * s:denite_win_height_percent),
    \ 'winrow': float2nr((&lines - (&lines * s:denite_win_height_percent)) / 2),
    \ })


" let s:floating_window_width_ratio = 1.0
" let s:floating_window_height_ratio = 0.7

" call denite#custom#option('default', {
" \ 'auto_action': 'preview_bat',
" \ 'floating_preview': v:true,
" \ 'match_highlight': v:true,
" \ 'preview_height': float2nr(&lines * s:floating_window_height_ratio),
" \ 'preview_width': float2nr(&columns * s:floating_window_width_ratio / 2),
" \ 'prompt': '% ',
" \ 'split': 'floating',
" \ 'vertical_preview': v:true,
" \ 'wincol': float2nr((&columns - (&columns * s:floating_window_width_ratio)) / 2),
" \ 'winheight': float2nr(&lines * s:floating_window_height_ratio),
" \ 'winrow': float2nr((&lines - (&lines * s:floating_window_height_ratio)) / 2),
" \ 'winwidth': float2nr(&columns * s:floating_window_width_ratio / 2),
" \ })
