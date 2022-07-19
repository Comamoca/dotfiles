let g:quickrun_config = get(g:, 'quickrun_config', {})
let g:quickrun_config._ = {
      \ 'outputter/buffer/opener': 'new',
      \ 'outputter/buffer/into': 1,
      \ 'outputter/buffer/close_on_empty': 1,
      \ }

let g:quickrun_config['qml/qmlscene'] = {
\	'command' : 'qmlscene',
\	'exec'    : '%c %s:p',
\	'runner'  : 'vimproc',
\ }
let g:quickrun_config['qml'] = g:quickrun_config['qml/qmlscene']
