local lspconfig = require("lspconfig")
-- local mason = require("mason")
-- local mason_lspconfig = require("mason-lspconfig")

require("lazydev").setup()

require("ddc_source_lsp_setup").setup()
local capabilities = require("ddc_source_lsp").make_client_capabilities()

local lspconfig = require("lspconfig")

lspconfig.metals.setup({})

-- when find `gleam.toml` in project root, start gleam lsp server.
if vim.fs.dirname(vim.fs.find({ "gleam.toml" }, { upward = true })[1]) then
  lspconfig.gleam.setup({
    capabilities = capabilities,
  })
end

if vim.fn.executable("racket") then
  if vim.fn.expand("%:e") == "ss" then
    return
  else
    require("lspconfig").racket_langserver.setup({})
  end
end

-- Language server settings
local servers = {
  "clangd",
  "rust_analyzer",
  "pyright",
  "ts_ls",
  "lua_ls",
  "nil_ls",
  "ruby_lsp",
  "gopls",
  "denols",
}

-- Auto start language servers.
for _, name in ipairs(servers) do
  -- for _, name in ipairs(lspconfig.util.available_servers()) do
  if name == "denols" or name == "tsserver" then
    local is_node_dir = function()
      return lspconfig.util.root_pattern('package.json')(vim.fn.getcwd() ~= nil)
    end

    -- ts_ls
    local ts_opts = {}
    ts_opts.on_attach = function(client)
      if not is_node_dir() then
        client.stop(true)
      end
    end
    lspconfig.ts_ls.setup(ts_opts)

    -- denols
    local deno_opts = {}
    deno_opts.on_attach = function(client)
      if is_node_dir() then
        client.stop(true)
      end
    end
    lspconfig.denols.setup(deno_opts)

  elseif name == "tailwindcss" then
    lspconfig.tailwindcss.setup({})
  -- lspconfig[name].setup({})

  elseif name == "efm" then
    lspconfig.tailwindcss.setup({
      init_options = {
        rootMarkers = {
          ".git/",
        },
      }
    })
  end
end

-- lsp keymaps
vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
vim.keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.formatting()<CR>")
vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
vim.keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
vim.keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")

-- vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
vim.keymap.set("n", "ga", "<cmd>Ddu lsp_definition<CR>")

vim.keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>")
vim.keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>")
vim.keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>")

vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
vim.keymap.set("n", "gs", "<cmd>Ddu nvim_lsp_references<CR>")
