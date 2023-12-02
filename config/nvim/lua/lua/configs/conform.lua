require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    javascript = { "deno_fmt" },
    typescript = { "deno_fmt" },
    typescriptreact = { "deno_fmt" },
    javascriptreact = { "deno_fmt" },
  },
})
