vim.call("skkeleton#config", { globalJisyo = "~/.skk/SKK-JISYO.L" })

local kmap = vim.keymap.set

kmap("i", "jk", "<Plug>(skkeleton-enable)")
kmap("i", "C-j", "<Plug>(skkeleton-enable)")
kmap("c", "jk", "<Plug>(skkeleton-enable")
