local lspconfig = require("lspconfig")
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

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
local lsp_settings = {
  tailwindcss = function(name)
    local fs = vim.fs
    local root_dir = fs.find({ "tailwind.config.js", "tailwind.config.ts" }, { upward = false })[1]

    if root_dir == nil then
      return
    end

    if fs.dirname(root_dir[1]) then
      lspconfig[name].setup({
        capabilities = capabilities,
      })
    end
  end,
  denols_tsserver = function(name)
    local node_root_dir = lspconfig.util.root_pattern("package.json")

    local is_node_repo = node_root_dir(vim.api.nvim_buf_get_name(0)) ~= nil

    local opts = {}

    if name == "tsserver" then
      if not is_node_repo then
        return
      end

      opts.root_dir = node_root_dir
    elseif name == "eslint" then
      if not is_node_repo then
        return
      end

      opts.root_dir = node_root_dir
    elseif name == "denols" then
      if is_node_repo then
        return
      end

      -- opts.root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc", "deps.ts", "import_map.json")
      opts.root_dir = lspconfig.util.root_pattern("*")

      opts.init_options = {
        lint = true,
        unstable = true,
        suggest = {
          imports = {
            hosts = {
              ["https://deno.land"] = true,
              ["https://jsr.io"] = true,
              ["https://cdn.nest.land"] = true,
              ["https://crux.land"] = true,
            },
          },
        },
      }
    end

    opts.on_attach = function(_, bufnr) end

    lspconfig[name].setup(opts)
  end,
}

-- maosn config
mason.setup()
mason_lspconfig.setup()
mason_lspconfig.setup_handlers({
  function(name)
    if name == "denols" or name == "tsserver" then
      lsp_settings.denols_tsserver(name)
    elseif name == "tailwindcss" then
      lsp_settings.tailwindcss(name)
    -- elseif name == "lua_ls" then
      -- return {
        -- diagnostics = {
        --   globals = { "vim" },
        -- },
        -- workspace = {
        --   library = {
        --     vim.env.VIMRUNTIME,
        --     vim.api.nvim_get_runtime_file("", true),
        --   },
        -- },
      -- }
    else
      require("lspconfig")[name].setup({})
    end
  end,
})

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
