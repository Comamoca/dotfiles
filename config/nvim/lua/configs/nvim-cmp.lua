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
local luasnip = require("luasnip")

local source_mapping = {
	buffer = "[Buffer]",
	nvim_lsp = "[LSP]",
	nvim_lua = "[Lua]",
	cmp_ai = "[AI]",
	path = "[Path]",
}

cmp.setup({
	snippet = {
		-- expand = function(args)
		-- 	vim.fn["UltiSnips#Anon"](args.body)
		-- end,
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "skkeleton" },
		{ name = "path" },
		{ name = "luasnip" },
		{ name = "buffer" },
		-- { name = "cmp_tabnine" },
		{ name = "codeium" },
		{ name = "emmet_vim" },
		{ name = "cmp_ai" },
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
		["<C-k>"] = cmp.mapping(function(fallback)
			if luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
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
	-- formatting = {
	-- 	format = function(entry, vim_item)
	-- 		-- if you have lspkind installed, you can use it like
	-- 		-- in the following line:
	--  		vim_item.kind = lspkind.symbolic(vim_item.kind, {mode = "symbol"})
	--  		vim_item.menu = source_mapping[entry.source.name]
	--  		if entry.source.name == "cmp_ai" then
	--
	--                        local detail = (entry.completion_item.labelDetails or {}).detail
	--  			vim_item.kind = ""
	--  			if detail and detail:find('.*%%.*') then
	--  				vim_item.kind = vim_item.kind .. ' ' .. detail
	--  			end
	--
	--  			if (entry.completion_item.data or {}).multiline then
	--  				vim_item.kind = vim_item.kind .. ' ' .. '[ML]'
	--  			end
	--  		end
	--  		local maxwidth = 80
	--  		vim_item.abbr = string.sub(vim_item.abbr, 1, maxwidth)
	--  		return vim_item
	--   end,
	--  }
	-- },
	experimental = {
		ghost_text = true,
	},
	view = {
		entries = "native",
	},
})
