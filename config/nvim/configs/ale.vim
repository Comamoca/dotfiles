let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1
let g:ale_sign_error = ''
let g:ale_sign_warning = ''
nmap <silent> <C-Shift-j> <Plug>(ale_next_wrap)
nmap <silent> <C-Shift-k> <Plug>(ale_previous_wrap)

let g:ale_linters = {
\   'nim': ['nimlint'],
\}
