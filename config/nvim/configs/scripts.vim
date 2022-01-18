" call term_start('mocp' . command, {
"  \ 'term_name': 'open moc',
"  \ 'curwin': v:true,
"  \ 'term_rows' : winheight('%'),
"  \ 'term_cols' : winwidth('%'),
"  \ 'term_finish': 'close',
"  \ })
"
" call term_start('mocp')


 " \ 'exit_cb': {status, code -> s:tig_callback(code)},
