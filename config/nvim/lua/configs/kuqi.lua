local util = require("lspconfig.util")

return {
	default_config = {
		cmd = { "kuqi" },
		filetypes = { "cotowali" },
		root_dir = function(fname)
			return util.root_pattern(".git")(fname)
		end,
		single_file_support = true,
	},
	docs = {
		description = [[
https://github.com/cotowali/cotowali

Cotowali language server.
]],
		default_config = {
			root_dir = [[root_pattern(".git")]],
		},
	},
}
