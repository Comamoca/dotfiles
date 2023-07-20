local sugar = require("comatools/sugar")

local ddu_patch_global = sugar.ddu_patch_global
local imap = sugar.imap
local nmap = sugar.nmap

local function sourceOption(source_opt)
	ddu_my_settings({ source_opt })
end

local function kindOption(kind_opt)
	ddu_my_settings({ kind_opt })
end

ddu_patch_global({
	kindOptions = {
		file = {
			defaultAction = "open",
		},
	},
})

ddu_patch_global({
	kindOptions = {
		file = {
			defaultAction = "open",
		},
	},
})

ddu_patch_global({
	kindOptions = {
		file = {
			defaultAction = "open",
		},
	},
})

ddu_patch_global({
	kindOptions = {
		["custom-list"] = {
			defaultAction = "callback",
		},
	},
})
