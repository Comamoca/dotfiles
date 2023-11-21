local filename = debug.getinfo(1).source:match("[^/]*$")
print(string.format("[[WARN]] @%s loading outside config file.", filename))
---

local ddc_custom_patch_global = vim.fn["ddc#custom#patch_global"]

ddc_custom_patch_global("ui", "native")
-- vim.fn["ddc#custom#patch_global"]('completionMenu', 'pum.vim')

ddc_custom_patch_global("sources", { "nvim-lsp", "around", "file" })
ddc_custom_patch_global("sourceOptions", {
  _ = {
    matchers = { "matcher_head" },
    sorters = { "sorter_rank" },
  },
  around = { mark = "around" },
  ["nvim-lsp"] = {
    mark = "LSP",
    forceCompletionPattern = ".w*|:w*|->w*",
  },
  path = {
    mark = "P",
  },
  file = {
    mark = "F",
    isVolatile = true,
    forceCompletionPattern = [[\S/\S*]],
  },
})

vim.fn["ddc#custom#patch_filetype"](
  { "ps1", "dosbatch", "autohotkey", "registry" },
  {
    sourceOptions = {
      file = {
        forceCompletionPattern = [[\S\\\S*]],
      },
    },
    sourceParams = {
      file = {
        mode = "win32",
      },
    },
  }
)

-- ddc_custom_patch_global("sourceParams", {
-- 	["nvim-lsp"] = { kindLabels = { Class = "c" } },
-- })

ddc_custom_patch_global("sourceParams", {
  ["nvim-lsp"] = {
    snippetEngine = vim.fn["denops#callback#register"](function(body)
      vim.fn["vsnip#anonymous"](body)
    end),
    enableResolveItem = true,
    enableAdditionalTextEdit = true,
  },
  path = {
    cmd = { "fd", "--max-depth", "5" },
  },
})

vim.fn["ddc#enable"]()

vim.cmd([[
inoremap <expr> <TAB>
	\ pumvisible() ? '<C-n>' :
	\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
	\ '<TAB>' : ddc#map#manual_complete()
]])

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function(event)
    vim.keymap.set({ "i", "s" }, "<Tab>", function()
      return vim.fn["vsnip#available"](1) == 1 and "<Plug>(vsnip-expand-or-jump)" or "<C-l>"
    end, { expr = true, noremap = false })

    vim.keymap.set({ "i", "s" }, "<C-k>", function()
      return vim.fn["vsnip#jumpable"](1) == 1 and "<Plug>(vsnip-jump-next)" or "<Tab>"
    end, { expr = true, noremap = false })

    vim.keymap.set({ "i", "s" }, "<C-j>", function()
      return vim.fn["vsnip#jumpable"](-1) == 1 and "<Plug>(vsnip-jump-prev)" or "<S-Tab>"
    end, { expr = true, noremap = false })

    vim.keymap.set({ "n", "s" }, "<s>", [[<Plug>(vsnip-select-text)]], { expr = true, noremap = false })
    vim.keymap.set({ "n", "s" }, "<S>", [[<Plug>(vsnip-cut-text)]], { expr = true, noremap = false })

    -- imap <expr><CR>   pumvisible() ? '<C-y>'   : '<CR>'
    vim.keymap.set("i", "<CR>", function()
      if vim.fn.pumvisible() == 1 then
        return "<C-y>"
      else
        return "<CR>"
      end
    end, { expr = true })
  end,
})
