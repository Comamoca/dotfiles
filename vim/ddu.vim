const width = &columns * 0.8
const col = &columns * 0.12

call ddu#custom#patch_global({
\   'ui': 'ff',
\   'sources': [
\     {
\       'name': 'file_rec',
\       'params': {
\         'ignoredDirectories': ['.git', 'node_modules', 'vendor', '.next']
\       }
\     }
\   ],
\   'sourceOptions': {
\     '_': {
\       'matchers': ['matcher_substring'],
\     },
\   },
\      'filterParams':  {
\        'matcher_fzf': {
\          'highlightMatched': 'Search',
\        },
\      },
\      'kindOptions': {
\        'file': {
\          'defaultAction': 'open',
\        },
\        'buffer': {
\          'defaultAction': 'open',
\        },
\	'memos': {
\          'defaultAction': 'open',
\	}
\      },
\     'uiParams': {
\        'ff': {
\          'startFilter': v:true,
\          'prompt': "> ",
\          'split': "horizontal",
\          'previewFloating': v:false,
\          'previewSplit': "vertical",
\          'previewFloatingBorder': "none",
\          'previewWidth': width * 0.7,
\          'previewHeight': col,
\          'autoAction': {
\            'name': "preview",
\          },
\        },
\ },
\ })

autocmd FileType ddu-ff call s:ddu_my_settings()
function! s:ddu_my_settings() abort
  nnoremap <buffer><silent> <CR>
    \ <Cmd>call ddu#ui#ff#do_action('itemAction', {'name': 'open'})<CR>

  nnoremap <buffer><silent> q
    \ <Cmd>call ddu#ui#ff#do_action('quit')<CR>

  set updatetime=500
  autocmd CursorHold * call ddu#ui#ff#do_action('preview')
  function! s:preview_hook() abort
    call ddu#ui#ff#do_action('preview')
  endfunction
endfunction

autocmd FileType ddu-ff-filter call s:ddu_filter_my_settings()
function! s:ddu_filter_my_settings() abort
  nnoremap <buffer><silent> q
  \ <Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>
  nnoremap <buffer><silent> <CR>
  \ <Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>
  inoremap <buffer><silent> <CR>
  \ <Esc><Cmd>call ddu#ui#do_action('itemAction')<CR>
  inoremap <buffer><silent> <C-c>
  \ <Esc><Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>
  inoremap <buffer><silent> <C-n>
  \ <Cmd>call ddu#ui#do_action('cursorNext')<CR>
  inoremap <buffer><silent> <C-p>
  \ <Cmd>call ddu#ui#do_action('cursorPrevious')<CR>
endfunction
