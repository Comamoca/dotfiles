call ddc#custom#patch_global('ui', 'pum')

call ddc#custom#patch_global('sources', [
\  'vim-lsp',
\  'around',
\  'vsnip',
\  'file',
\])

call ddc#custom#patch_global('sourceOptions', #{
    \   vim-lsp: #{
    \     matchers: ['matcher_head'],
    \     mark: 'lsp',
    \   },
    \ })

call ddc#custom#patch_global('sourceOptions', {
\  '_': {
\    'matchers': [ 'matcher_fuzzy' ],
\    'sorters': [ 'sorter_fuzzy' ],
\    'converters': [ 'converter_fuzzy' ],
\  },
\  'around': { 'mark': 'around' },
\  'path': { 'mark': 'P' },
\  'file': {
\    'mark': 'F',
\    'isVolatile': v:true,
\    'forceCompletionPattern': '\S/\S*',
\  },
\  'vsnip': { 'mark': 'vsnip' },
\})

call ddc#custom#patch_filetype([ 'ps1', 'dosbatch', 'autohotkey', 'registry' ], {
\   'sourceOptions': {
\     'file': {
\       'forceCompletionPattern': '\S\\\S*',
\     },
\   },
\   'sourceParams': {
\     'file': {
\       'mode': 'win32',
\     },
\   },
\ })


call ddc#custom#patch_global('sourceParams', {
\  'path': {
\     'cmd': [ 'fd', '--max-depth', '5' ],
\   },
\ })

call ddc#enable()

" inoremap <S-Tab> <Cmd>call pum#map#insert_relative(-1)<CR>
inoremap <C-n>   <Cmd>call pum#map#select_relative(+1)<CR>
inoremap <C-p>   <Cmd>call pum#map#select_relative(-1)<CR>
inoremap <Tab>   <Cmd>call pum#map#confirm()<CR>
inoremap <silent><expr> <CR> pum#visible() ? '<cmd>call pum#map#confirm()<CR>' : '<cr>'
inoremap <C-e>   <Cmd>call pum#map#cancel()<CR>

" inoremap <expr> <TAB>
" 	\ pumvisible() ? '<C-n>' :
" 	\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
" 	\ '<TAB>' : ddc#map#manual_complete()
