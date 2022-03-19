call skkeleton#config({ 'globalJisyo': '~/.skk/SKK-JISYO.L' })


function! s:skkeleton_init() abort
  call skkeleton#config({
    \ 'globalJisyo': "~/.skk/SKK-JISYO.L",
    \ 'globalJisyoEncoding': "utf-8"
    \ })
endfunction
augroup skkeleton-initialize-pre
  autocmd!
  autocmd User skkeleton-initialize-pre call s:skkeleton_init()
augroup END

imap <C-d> <Plug>(skkeleton-enable)
cmap <C-d> <Plug>(skkeleton-enable)

" imap jj <Plug>(skkeleton-disable)
" cmap jj <Plug>(skkeleton-disable)
