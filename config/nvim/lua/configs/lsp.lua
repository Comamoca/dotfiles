require("ddc_source_lsp_setup").setup()

-- astro: home.nix で pkgs.typescript を ~/.cache/nvim-lsp/typescript に配置済み
vim.lsp.config("astro", {
  cmd = { "astro-ls", "--stdio" },
  init_options = {
    typescript = {
      tsdk = vim.fn.expand("~/.cache/nvim-lsp/typescript"),
    },
  },
})
vim.lsp.enable("astro")

-- ts_ls: package.json があるプロジェクトでのみ起動
vim.lsp.config("ts_ls", {
  root_markers = { "package.json", "tsconfig.json" },
})
vim.lsp.enable("ts_ls")

-- denols: deno.json があるプロジェクトでのみ起動
vim.lsp.config("denols", {
  root_markers = { "deno.json", "deno.jsonc" },
})
vim.lsp.enable("denols")

-- lsp keymaps
vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
vim.keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.formatting()<CR>")
vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
vim.keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
vim.keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")

vim.keymap.set("n", "ga", "<cmd>Ddu lsp_definition<CR>")

vim.keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>")
vim.keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>")
vim.keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>")

vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
vim.keymap.set("n", "gs", "<cmd>Ddu nvim_lsp_references<CR>")
