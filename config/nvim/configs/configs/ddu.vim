" You must set the default ui.
" Note: ff ui
" https://github.com/Shougo/ddu-ui-ff
call ddu#custom#patch_global({
    \ 'ui': 'ff',
    \ })

" You must set the default action.
" Note: file kind
" https://github.com/Shougo/ddu-kind-file
call ddu#custom#patch_global({
    \   'kindOptions': {
    \     'file': {
    \       'defaultAction': 'open',
    \     },
    \   }
    \ })

" Specify matcher.
" Note: matcher_substring filter
" https://github.com/Shougo/ddu-filter-matcher_substring
" call ddu#custom#patch_global({
"     \   'sourceOptions': {
"     \     '_': {
"     \       'matchers': ['matcher_substring'],
"     \     },
"     \   }
"     \ })

" Set default sources
" Note: file source
" https://github.com/Shougo/ddu-source-file
call ddu#custom#patch_global({
    \ 'sources': [{'name': 'file', 'params': {}}],
    \ })

" Change source options.
call ddu#custom#patch_global('sourceParams', {
      \ 'file_rec': {'path': expand('~')},
      \ })

call ddu#custom#patch_global({
    \   'sourceOptions': {
    \     '_': {
    \       'matchers': ['matcher_fzf'],
    \     },
    \   }
    \ })


" Call default sources{{{
" call ddu#start({})

" Set name specific configuration
" call ddu#custom#patch_local('files', {
"     \ 'sources': [
"     \   {'name': 'file', 'params': {}},
"     \   {'name': 'file_old', 'params': {}},
"     \ ],
"     \ })

" Specify name
" call ddu#start({'name': 'files'})

" Specify source with params
" Note: file_rec source
" https://github.com/Shougo/ddu-source-file_rec
" call ddu#start({'sources': [
"     \ {'name': 'file_rec', 'params': {'path': expand('~')}}
"     \ ]})}}}
