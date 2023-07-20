local sugar = require("comatools/sugar")

local ddu_patch_global = sugar.ddu_patch_global
local imap = sugar.imap
local nmap = sugar.nmap

local function sourceOption(source_opt)
	ddu_my_settings({ source_opt })
end

ddu_patch_global({
	sources = {
		name = "file",
		ui = "ff",
		params = {},
	},
})

ddu_patch_global({
	sourceParams = {
		rg = {
			args = { "--column", "--no-heading", "--color", "never" },
		},
	},
})

ddu_patch_global({
	sourceOptions = {
		_ = {
			matchers = { "matcher_substring" },
		},
	},
})
