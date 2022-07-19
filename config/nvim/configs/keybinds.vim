" Keybinds

" nnoremap <[><[> :nohlsearch
"

noremap <S-j>   }
noremap <S-k>   {
"

" nnoremap ; :
" nnoremap : ;
nnoremap <silent><C-f> :<C-u>call Close()<cr>

inoremap <silent>jj <Esc>

tnoremap <Esc> <C-\><C-n>
" tnoremap <c-f> :<c-u>call TermClose()<CR>
tnoremap <C-[><C-[> <C-\><C-n>
tnoremap <silent><C-f> <C-\><C-n>:bw!<CR>
" nnoremap <silent><C-f> <C-\><C-n>:bw! term://<CR>
tnoremap <C-[><C-[>   <C-\><C-n>
" tnoremap <silent> jj <C-\><C-n>

nnoremap <Esc><Esc> :<C-u>nohlsearch<CR>
nnoremap <C-[><C-[> <Esc><Esc>
noremap <silent><C-o> :Denite buffer<CR>

set completeopt=menuone,noinsert
" 補完表示時のEnterで改行をしない
inoremap <expr><CR>  pumvisible() ? "<C-y>" : "<CR>"

" nnoremap <silent><C-o> :<c-u>call ddu#start({'sources': [{'name': 'buffer'}]})<cr>
" nnoremap <silent><C-o> :<c-u>Denite buffer<cr>
" nnoremap <silent><C-p> :<c-u>call ddu#start({'sources': [{'name': 'file_rec', 'params': {'path': expand(getcwd())}}]})<cr>
" nnoremap <silent><C-p> :<c-u>Denite file/rec<CR>

nnoremap <silent><C-o> :Telescope buffers<CR>
nnoremap <silent><C-p> :Telescope find_files<CR>

" nnoremap <silent><C-o> :Ddu buffer<CR>
" nnoremap <silent><C-p> :Ddu file_rec<CR>

nnoremap <Leader>q :<C-u>bw! quickrun://output<CR>
command! QuickRunClose :<C-u>bw! quickrun://output<CR>
nnoremap <silent><C-t> :<C-u>call DeolFloat()<CR>

nnoremap sv :<C-u>vs<CR>
nnoremap sp :<C-u>sp<CR>

function! Close() abort
	try
		:close
	catch
		:bd
	endtry
endfunction

" nnoremap <silent><C-l> :<C-u>Ddu line<CR>

function! VartDeol() abort
		:vs
		:Deol
endfunction

nnoremap sd :call VartDeol()<CR>
