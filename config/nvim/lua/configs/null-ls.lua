-- {{{
local async_formatting = function(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	vim.lsp.buf_request(
		bufnr,
		"textDocument/formatting",
		vim.lsp.util.make_formatting_params({}),
		function(err, res, ctx)
			if err then
				local err_msg = type(err) == "string" and err or err.message
				-- you can modify the log message / level (or ignore it completely)
				vim.notify("formatting: " .. err_msg, vim.log.levels.WARN)
				return
			end

			-- don't apply results if buffer is unloaded or has been modified
			if not vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_buf_get_option(bufnr, "modified") then
				return
			end

			if res then
				local client = vim.lsp.get_client_by_id(ctx.client_id)
				vim.lsp.util.apply_text_edits(res, bufnr, client and client.offset_encoding or "utf-16")
				vim.api.nvim_buf_call(bufnr, function()
					vim.cmd("silent noautocmd update")
				end)
			end
		end
	)
end
-- }}}
local null_ls = require("null-ls")

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

require("null-ls").setup({
	-- you can reuse a shared lspconfig on_attach callback here
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.deno_fmt,
		null_ls.builtins.formatting.rustfmt,
		null_ls.builtins.formatting.nimpretty,
		-- Go
		null_ls.builtins.formatting.gofumpt,
		null_ls.builtins.formatting.golines,
		-- Python
		null_ls.builtins.formatting.isort,
		null_ls.builtins.formatting.ruff,
		null_ls.builtins.formatting.yapf,

		-- Dart
		null_ls.builtins.formatting.dart_format,
	},
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
					vim.lsp.buf.format()
				end,
			})
		end
	end,
})
