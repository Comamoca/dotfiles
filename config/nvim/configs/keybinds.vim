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

set completeopt=menuone,noinsert
" 補完表示時のEnterで改行をしない
inoremap <expr><CR>  pumvisible() ? "<C-y>" : "<CR>"







