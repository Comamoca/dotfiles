require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })

local hop = require("hop")
-- local directions = require("hop.hint").HintDirection

-- vim.keymap.set("", "<Leader><Leader>", function()
-- 	hop.hint_patterns()
-- end, { remap = true })

-- move to up line on cursor
vim.keymap.set("", "<Leader>k", function()
	hop.hint_vertical()
end)

vim.keymap.set("", "<Leader>w", function()
	hop.hint_words()
end)
