-- -- cmp_nvim_lsp.update_capabilities is deprecated, use cmp_nvim_lsp.default_capabilities instead. See :h deprecated{{{
-- require("cmp_nvim_ultisnips").setup({})
-- local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")
-- local cmp = require("cmp")
-- local lspkind = require("lspkind")
--
-- cmp.setup({
-- 	snippet = {
-- 		expand = function(args)
-- 			vim.fn["UltiSnips#Anon"](args.body)
-- 		end,
-- 	},
-- 	sources = {
-- 		{ name = "nvim_lsp" },
-- 		{ name = "skkeleton" },
-- 		{ name = "path" },
-- 		-- { name = "buffer" },
-- 	},
-- 	mapping = cmp.mapping.preset.insert({
-- 		["<C-p>"] = cmp.mapping.select_prev_item(),
-- 		["<C-n>"] = cmp.mapping.select_next_item(),
-- 		["<C-l>"] = cmp.mapping.complete(),
-- 		["<C-e>"] = cmp.mapping.abort(),
-- 		["<CR>"] = cmp.mapping.confirm({
-- 			select = true,
-- 		}),
-- 		["<Tab>"] = cmp.mapping(function(fallback)
-- 			cmp_ultisnips_mappings.expand_or_jump_forwards(fallback)
-- 		end, {
-- 			"i",
-- 			"s", --[[ "c" (to enable the mapping in command mode) ]]
-- 		}),
-- 		["<S-Tab>"] = cmp.mapping(function(fallback)
-- 			cmp_ultisnips_mappings.jump_backwards(fallback)
-- 		end, {
-- 			"i",
-- 			"s", --[[ "c" (to enable the mapping in command mode) ]]
-- 		}),
-- 	}),
-- 	formatting = {
-- 		format = lspkind.cmp_format({
-- 			mode = "symbol", -- show only symbol annotations
-- 			maxwidth = 60, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
-- 			ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
-- 			-- The function below will be called before any actual modifications from lspkind
-- 			-- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
-- 		}),
-- 	},
-- 	experimental = {
-- 		ghost_text = true,
-- 	},
-- 	view = {
-- 		entries = "native",
-- 	},
-- })
--
-- -- cmp.setup.cmdline('/', {
-- --   mapping = cmp.mapping.preset.cmdline(),
-- --   sources = {
-- --     { name = 'buffer' }
-- --   }
-- -- })
-- -- cmp.setup.cmdline(":", {
-- --   mapping = cmp.mapping.preset.cmdline(),
-- --   sources = {
-- --     { name = "cmdline" },
-- --   },
-- -- })}}}

require("cmp_nvim_ultisnips").setup({})
local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")
local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn["UltiSnips#Anon"](args.body)
		end,
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "skkeleton" },
		{ name = "path" },
		-- { name = "buffer" },
		-- { name = "cmp_tabnine" },
		{ name = "codeium" },
		{ name = "emmet_vim" },
	},
	mapping = {
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.close(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end,
		["<S-Tab>"] = function(fallback)
			if cmp.visivle() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end,
	},
	formatting = {
		-- format = lspkind.cmp_format({
		-- 	mode = "symbol",
		-- 	maxwidth = 60,
		-- 	ellipsis_char = "...",
		-- }),
		format = require("lspkind").cmp_format({
			mode = "symbol",
			maxwidth = 50,
			ellipsis_char = "...",
			symbol_map = { Codeium = "" },
		}),
	},
	experimental = {
		ghost_text = true,
	},
	view = {
		entries = "native",
	},
})
