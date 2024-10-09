call skkeleton#azik#add_table("jis")

call skkeleton#config(#{
\   globalDictionaries: [ "~/.skk/SKK-JISYO.L",
\                         "~/.skk/SKK-JISYO.im@sparql.all.utf8" ],
\   databasePath: "~/.vim/skk/database",
\   kanaTable: "azik"
\   })


call skkeleton#register_keymap('henkan', "<", 'purgeCandidate')
call skkeleton#register_keymap('henkan', "X", '')

call skkeleton#register_keymap('henkan', "<S-q>", 'purgeCandidate')
call skkeleton#register_keymap('henkan', "X", '')

call skkeleton#register_keymap('input', ';', 'henkanPoint')


autocmd InsertEnter * ++once call skkeleton#register_kanatable('azik', {
    \   'jj':         'escape',
    \   '@':          'katakana',
    \   "'":          'hankatakana',
    \   '<s-j><s-j>': ['じゅん', ''],
    \   '<s-j>i':     ['じ', ''],
    \   '<s-j>p':     ['じょう', ''],
    \   '<s-j>o':     ['じょ', ''],
    \   '<s-j>k':     ['じん', ''],
    \   '<s-j>u':     ['じゅ', ''],
    \   'l':          ['っ', ''],
    \   'la':         ['', ''],
    \   'li':         ['', ''],
    \   'lu':         ['', ''],
    \   'le':         ['', ''],
    \   'lo':         ['', ''],
    \   'xxa':        ['ぁ', ''],
    \   'xxi':        ['ぃ', ''],
    \   'xxu':        ['ぅ', ''],
    \   'xxe':        ['ぇ', ''],
    \   'xxo':        ['ぉ', ''],
    \   'n':          ['ん', ''],
    \   'z=':         ['＝', ''],
    \   'z~':         ['～', ''],
    \   'z ':         ['　', ''],
    \   'z:':         ['：', ''],
    \ })


imap <C-i> <Plug>(skkeleton-enable)
imap <C-l> <Plug>(skkeleton-disable)
