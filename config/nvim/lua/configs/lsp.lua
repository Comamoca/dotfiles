local filename = debug.getinfo(1).source:match("[^/]*$")
print(string.format("[[WARN]] @%s loading outside config file.", filename))

require("mason").setup({
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

require("ddc_nvim_lsp_setup").setup()
require("neodev").setup({})

local nvim_lsp = require("lspconfig")
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers({
  function(server_name)
    local opts = {}
    opts.on_attach = function(_, bufnr) end

    local node_root_dir = nvim_lsp.util.root_pattern("package.json")
    local is_node_repo = node_root_dir(vim.api.nvim_buf_get_name(0)) ~= nil

    if server_name == "tsserver" then
      if not is_node_repo then
        return
      end

      opts.root_dir = node_root_dir
      -- elseif server_name == "java_language_server" then
      --      require("lspconfig").java_language_server.setup({})
    elseif server_name == "eslint" then
      if not is_node_repo then
        return
      end

      opts.root_dir = node_root_dir
    elseif server_name == "denols" then
      if is_node_repo then
        return
      end

      -- opts.root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc", "deps.ts", "import_map.json")
      opts.root_dir = nvim_lsp.util.root_pattern("*")
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
      opts.cmd = { "/home/coma/.local/share/nvim/mason/bin/elixir-ls" }
      -- nvim_lsp["elixirls"].setup({
      --      cmd = { "/home/coma/.local/share/nvim/mason/bin/elixir-ls" },
      -- })
    elseif server_name == "lua-language-server" then
      nvim_lsp.sumneko_lua.setup({
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

    if server_name == "denols" then
      require("lspconfig").denols.setup({
        capabilities = require("ddc_nvim_lsp").make_client_capabilities(),
      })
    else
      nvim_lsp[server_name].setup(opts)
    end
  end,
})
