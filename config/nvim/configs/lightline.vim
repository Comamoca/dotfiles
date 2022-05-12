let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename' ] ],
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename',
      \   'gitgutter': 'GitGutter'
      \ },
      \  'separator': { 'left': "", 'right': "" },
      \  'subseparator' :{ 'left': '|', 'right': '|' }
      \ }

let g:gitgutter_sign_added = '🟢'
let g:gitgutter_sign_modified = '➡ '
let g:gitgutter_sign_removed = '🔴'

function! GitGutter()
  if ! exists('*GitGutterGetHunkSummary')
        \ || ! get(g:, 'gitgutter_enabled', 0)
        \ || winwidth('.') <= 90
    return ''
  endif
  let symbols = [
        \ g:gitgutter_sign_added . ' ',
        \ g:gitgutter_sign_modified . ' ',
        \ g:gitgutter_sign_removed . ' '
        \ ]
  let hunks = GitGutterGetHunkSummary()
  let ret = []
  for i in [0, 1, 2]
    if hunks[i] > 0
      call add(ret, symbols[i] . hunks[i])
    endif
  endfor
  return join(ret, ' ')
endfunction

function! LightlineFilename()
  let filename = expand('%:t') !=# '' ? expand('%:t') : 'ﾌﾞｫﾝ=͟͟͞͞💩'     
  let modified = &modified ? ' +' : ''
  return filename . modified
endfunction
