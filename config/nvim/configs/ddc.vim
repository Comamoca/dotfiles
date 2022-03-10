"" Use around source.
"call ddc#custom#patch_global('sources', ['around'])

"" Use matcher_head and sorter_rank.
""{{{
"call ddc#custom#patch_global('sources', ['file'])
"call ddc#custom#patch_global('sourceOptions', {
"    \ 'file': {
"    \   'mark': 'F',
"    \   'isVolatile': v:true,
"    \   'forceCompletionPattern': '\S/\S*',
"    \ }})
"call ddc#custom#patch_filetype(
"    \ ['ps1', 'dosbatch', 'autohotkey', 'registry'], {
"    \ 'sourceOptions': {
"    \   'file': {
"    \     'forceCompletionPattern': '\S\\\S*',
"    \   },
"    \ },
"    \ 'sourceParams': {
"    \   'file': {
"    \     'mode': 'win32',
"    \   },
"    \ }})"}}}

"call ddc#custom#patch_global('sources', ['ddc-path'])
"call ddc#custom#patch_global('sourceParams', {
"\   'path': { 'mark': 'P', 'cmd': ['fd', '--max-depth', '5'] }
"\ })

"call ddc#custom#patch_global('sources', ['ultisnips'])"{{{
"call ddc#custom#patch_global('sourceOptions', {
"      \ '_': {'matchers': ['matcher_head']},
"      \ 'ultisnips': {'mark': 'US'},
"      \ })"}}}

"call ddc#custom#patch_global('sources', ['skkeleton'])
"call ddc#custom#patch_global('sourceOptions', {
"    \   '_': {
"    \     'matchers': ['matcher_head'],
"    \     'sorters': ['sorter_rank']
"    \   },
"    \   'skkeleton': {
"    \     'mark': 'skkeleton',
"    \     'matchers': ['skkeleton'],
"    \     'sorters': [],
"    \     'minAutoCompleteLength': 2,
"    \   },
"    \ })



"call ddc#custom#patch_global('sourceOptions', {
"      \ '_': {
"      \   'matchers': ['matcher_head'],
"      \   'sorters': ['sorter_rank']},
"      \ })

"" call ddc#custom#patch_global('sources', ['vim-lsp'])
""  call ddc#custom#patch_global('sourceOptions', {
""      \ 'vim-lsp': {
""      \   'matchers': ['matcher_head'],
""      \   'mark': 'lsp',
""      \ },
""      \ })

" " Mappings

"" <TAB>: completion.
"inoremap <silent><expr> <TAB>
"\ ddc#map#pum_visible() ? '<C-n>' :
"\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
"\ '<TAB>' : ddc#map#manual_complete()

"" <S-TAB>: completion back.
"inoremap <expr><S-TAB>  ddc#map#pum_visible() ? '<C-p>' : '<C-h>'

"" Use ddc
"" call ddc#enable()
