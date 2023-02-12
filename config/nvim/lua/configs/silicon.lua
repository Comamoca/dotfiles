vim.cmd([[
let g:silicon = {
      \   'theme':              'gruvbox-dark',
      \   'font':                  'Hack',
      \   'background':         '#b4cf8f',
      \   'shadow-color':       '#555555',
      \   'line-pad':                   2,
      \   'pad-horiz':                 80,
      \   'pad-vert':                 100,
      \   'shadow-blur-radius':         0,
      \   'shadow-offset-x':            0,
      \   'shadow-offset-y':            0,
      \   'line-number':           v:true,
      \   'round-corner':          v:true,
      \   'window-controls':       v:true,
      \ }
]])

vim.g.silicon["output"] = "{time:%Y-%m-%d-%H%M%S}.png"
