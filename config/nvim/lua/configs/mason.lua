local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local nvim_lsp = require("lspconfig")

mason.setup({
	ui = {
		icons = {
			server_installed = "✓",
			server_pending = "➜",
			server_uninstalled = "✗",
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

-- nvim_lsp.dartls.setup({})

-- if is_node_repo then{{{
-- 	nvim_lsp["tsserver"].setup({
-- 		root_dir = nvim_lsp.util.root_pattern("package.json"),
-- 	})
-- else
-- 	nvim_lsp["denols"].setup({
-- 		root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc"),
-- 		init_options = {
-- 			lint = true,
-- 			unstable = true,
-- 			suggest = {
-- 				imports = {
-- 					hosts = {
-- 						["https://deno.land"] = true,
-- 						["https://cdn.nest.land"] = true,
-- 						["https://crux.land"] = true,
-- 					},
-- 				},
-- 			},
-- 		},
-- 	})
-- end}}}

local opts = {}

local check = vim.fn.getftype

-- require("mason-lspconfig").setup_handlers({
-- 	function(server)
-- 		local opt = {
-- 			capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol
-- 			.make_client_capabilities()),
-- 		}
-- 		require("lspconfig")[server].setup(opt)
--
-- 		local node_root_dir = nvim_lsp.util.root_pattern("package.json")
-- 		local is_node_repo = node_root_dir(vim.api.nvim_buf_get_name(0)) ~= nil
-- 	end,
-- })

mason_lspconfig.setup_handlers({
	function(server_name)
		local node_root_dir = nvim_lsp.util.root_pattern("package.json")
		local is_node_repo = node_root_dir(vim.api.nvim_buf_get_name(0)) ~= nil

		local opts = {}

		if server_name == "tsserver" then
			if not is_node_repo then
				return
			end

			opts.root_dir = node_root_dir
		elseif server_name == "eslint" then
			if not is_node_repo then
				return
			end

			opts.root_dir = node_root_dir
		elseif server_name == "denols" then
			if is_node_repo then
				return
			end

			opts.root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc", "deps.ts",
				"import_map.json")
			opts.init_options = {
				lint = true,
				unstable = true,
				suggest = {
					imports = {
						hosts = {
							["https://deno.land"] = true,
							["https://cdn.nest.land"] = true,
							["https://crux.land"] = true,
						},
					},
				},
			}
			opts.cmd = { "deno", "lsp", "--unstable" }
		elseif server_name == "elixirls" then
			require("lspconfig").elixirls.setup({
				-- Unix
				cmd = { "/home/coma/.local/share/nvim/mason/bin/elixir-ls" },
			})
		elseif server_name == "lua-language-server" then
			require("lspconfig").sumneko_lua.setup({
				settings = {
					Lua = {
						runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
						diagnostics = {
							-- Get the language server to recognize the `vim` global
							enable = true,
							globals = { "vim" },
						},
					},
				},
			})
		end

		opts.on_attach = function(_, bufnr)
			-- 略
		end

		nvim_lsp[server_name].setup(opts)
	end,
})

-- keyboard shortcut
vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
vim.keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.formatting()<CR>")
vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
vim.keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
vim.keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")
vim.keymap.set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
vim.keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>")
vim.keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>")
vim.keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>")

-- LSP handlers
vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = true })

-- vim.cmd([[
-- highlight LspDiagnosticsSignError ctermbg=9 ctermfg=15
-- highlight LspDiagnosticsSignHint ctermbg=142 ctermfg=15
-- ]])
