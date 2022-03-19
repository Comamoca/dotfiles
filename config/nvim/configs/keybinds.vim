" Keybinds

" nnoremap <[><[> :nohlsearch
"

noremap <S-j>   }
noremap <S-k>   {
"

nnoremap ; :
nnoremap <silent><C-f> :<C-u>bd<CR>
" nnoremap jj <C-[>

inoremap <silent>jj <Esc>

tnoremap <Esc> <C-\><C-n>
tnoremap <C-[><C-[> <C-\><C-n>

noremap <C-[><C-[> :nohlsearch<CR>
noremap <silent><C-o> :Denite buffer<CR>

set completeopt=menuone,noinsert
" 補完表示時のEnterで改行をしない
inoremap <expr><CR>  pumvisible() ? "<C-y>" : "<CR>"

nnoremap <silent><C-o> :<c-u>call ddu#start({'sources': [{'name': 'buffer'}]})<cr>
nnoremap <silent><C-o> :<c-u>Denite buffer<cr>
" nnoremap <silent><C-p> :<c-u>call ddu#start({'sources': [{'name': 'file_rec', 'params': {'path': expand(getcwd())}}]})<cr>
nnoremap <silent><C-p> :<c-u>Denite file/rec<CR>
