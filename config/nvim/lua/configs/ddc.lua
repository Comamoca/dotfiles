local ddc_custom_patch_global = vim.fn["ddc#custom#patch_global"]

local pum_map_select_relative = vim.fn["pum#map#select_relative"]
local pum_map_confirm = vim.fn["pum#map#confirm"]
local pum_map_cancel = vim.fn["pum#map#cancel"]
local pum_visible = vim.fn["pum#visible"]
local pum_entered = vim.fn["pum#entered"]

ddc_custom_patch_global("ui", "pum")

ddc_custom_patch_global("sources", {
	"lsp",
	"around",
	"vsnip",
	"file",
	"skkeleton",
	"emoji",
})

ddc_custom_patch_global("sourceOptions", {
	["lsp"] = {
		dup = "keep",
		mark = "LSP",
		forceCompletionPattern = "\\.\\w*|:\\w*|->\\w*",
	},
})

ddc_custom_patch_global("sourceParams", {
	lsp = {
		snippetEngine = vim.fn["denops#callback#register"]({
			function(body)
				vim.fn["vsnip#anonymous"](body)
			end,
		}),
		enableResolveItem = true,
		enableAdditionalTextEdit = true,
		sorters = {'sorter_lsp-kind'},
		kindLabels = { Class = 'c' }
	},
})

ddc_custom_patch_global("sourceOptions", {
	skkeleton = {
		mark = "SKK",
		matchers = {},
		sorters = {},
		isVolatile = true,
	},
})

ddc_custom_patch_global("sourceOptions", {
	emoji = {
		mark = "emoji",
		matchers = { "emoji" },
		sorters = {},
	},
})

ddc_custom_patch_global("sourceOptions", {
	_ = {
		-- matchers = { "matcher_head" },
		-- sorters = { "sorter_rank" },

		matchers = { "matcher_fuzzy" },
		sorters = { "sorter_fuzzy" },
		converters = { "converter_fuzzy" },
		-- keywordPattern = "[a-zA-Z_:]\\w*",
		keywordPattern = "\\k+",
	},
	around = { mark = "around" },
	path = {
		mark = "P",
	},
	file = {
		mark = "F",
		isVolatile = true,
		forceCompletionPattern = [[\S/\S*]],
	},
	vsnip = {
		mark = "vsnip",
	},
})

vim.fn["ddc#custom#patch_filetype"]({ "ps1", "dosbatch", "autohotkey", "registry" }, {
	sourceOptions = {
		file = {
			forceCompletionPattern = [[\S\\\S*]],
		},
	},
	sourceParams = {
		file = {
			mode = "win32",
		},
	},
})

ddc_custom_patch_global("sourceParams", {
	path = {
		cmd = { "fd", "--max-depth", "5" },
	},
})

vim.fn["ddc#enable_terminal_completion"]()
vim.fn["ddc#enable"]()

-- vim.cmd([[
-- inoremap <expr> <TAB>
-- 	\ pumvisible() ? '<C-n>' :
-- 	\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
-- 	\ '<TAB>' : ddc#map#manual_complete()
-- ]])

vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function(event)
		vim.keymap.set({ "i", "s" }, "<Tab>", function()
			return vim.fn["vsnip#available"](1) == 1 and "<Plug>(vsnip-expand-or-jump)" or "<C-l>"
		end, { expr = true, noremap = false })

		vim.keymap.set({ "i", "s" }, "<C-k>", function()
			return vim.fn["vsnip#jumpable"](1) == 1 and "<Plug>(vsnip-jump-next)" or "<Tab>"
		end, { expr = true, noremap = false })

		vim.keymap.set({ "i", "s" }, "<C-j>", function()
			return vim.fn["vsnip#jumpable"](-1) == 1 and "<Plug>(vsnip-jump-prev)" or "<S-Tab>"
		end, { expr = true, noremap = false })

		vim.keymap.set({ "n", "s" }, "<s>", [[<Plug>(vsnip-select-text)]], { expr = true, noremap = false })
		vim.keymap.set({ "n", "s" }, "<S>", [[<Plug>(vsnip-cut-text)]], { expr = true, noremap = false })

		vim.keymap.set("i", "<C-p>", function()
			pum_map_select_relative(-1)
		end, {})

		vim.keymap.set("i", "<C-n>", function()
			pum_map_select_relative(1)
		end, {})

		vim.keymap.set("i", "<C-y>", function()
			return '<Cmd>call pum#map#confirm()<CR>'
		end, { expr = true, silent = true })

		vim.keymap.set("i", "<CR>", function()
			return pum_visible() and '<Cmd>call pum#map#confirm()<CR>' or '<CR>'
		end, { expr = true, silent = true })
	end
})
