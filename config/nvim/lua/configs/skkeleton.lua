vim.call("skkeleton#config", { globalJisyo = "~/.skk/SKK-JISYO.L" })

local kmap = vim.keymap.set

kmap("i", "<C-j>", "<Plug>(skkeleton-toggle)")
kmap("c", "<C-j>", "<Plug>(skkeleton-toggle)")
