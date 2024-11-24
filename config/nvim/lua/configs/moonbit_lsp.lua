local util = require("lspconfig.util")

return {
  default_config = {
    cmd = { "moonbit-lsp" },
    filetypes = { "moonbit" },
    root_dir = util.root_pattern("moon.mod.json"),
  },
  docs = {
    description = [[
The moonbit language server.

```sh
npm install -g @moonbit/moonbit-lsp
```
]],
  },
}
