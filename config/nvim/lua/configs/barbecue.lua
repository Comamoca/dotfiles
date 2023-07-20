require("barbecue").setup({
	theme = {
		-- normal = { fg = "#c0caf5" },
		-- normal = { fg = "#d3ebe9" },

		-- ellipsis = { fg = "#737aa2" },
		ellipsis = { fg = "#33859e" },
		separator = { fg = "#33859e" },
		modified = { fg = "#33859e" },

		dirname = { fg = "#33859e" },
		basename = { bold = true },
		context = {},

		context_file = { fg = "#599cab" },
		context_module = { fg = "#599cab" },
		context_namespace = { fg = "#599cab" },
		context_package = { fg = "#599cab" },
		context_class = { fg = "#599cab" },
		context_method = { fg = "#599cab" },
		context_property = { fg = "#599cab" },
		context_field = { fg = "#599cab" },
		context_constructor = { fg = "#599cab" },
		context_enum = { fg = "#599cab" },
		context_interface = { fg = "#599cab" },
		context_function = { fg = "#599cab" },
		context_variable = { fg = "#599cab" },
		context_constant = { fg = "#599cab" },
		context_string = { fg = "#599cab" },
		context_number = { fg = "#599cab" },
		context_boolean = { fg = "#599cab" },
		context_array = { fg = "#599cab" },
		context_object = { fg = "#599cab" },
		context_key = { fg = "#599cab" },
		context_null = { fg = "#599cab" },
		context_enum_member = { fg = "#599cab" },
		context_struct = { fg = "#599cab" },
		context_event = { fg = "#599cab" },
		context_operator = { fg = "#599cab" },
		context_type_parameter = { fg = "#599cab" },
	},
	create_autocmd = false,
})

vim.opt.updatetime = 200

vim.api.nvim_create_autocmd({
	"WinScrolled",
	"BufWinEnter",
	"CursorHold",
	"InsertLeave",

	"BufModifiedSet",
}, {
	group = vim.api.nvim_create_augroup("barbecue.updater", {}),
	callback = function()
		require("barbecue.ui").update()
	end,
})
