local ddc_custom_patch_global = vim.fn["ddc#custom#patch_global"]

ddc_custom_patch_global("ui", "native")
-- vim.fn["ddc#custom#patch_global"]('completionMenu', 'pum.vim')

ddc_custom_patch_global("sources", {
  -- "nvim-lsp",
  -- "lsp",
  -- "around",
  -- "vsnip",
  -- "file",
  "skkeleton",
  "emoji",
})

ddc_custom_patch_global("sourceOptions", {
  emoji = {
    mark = "emoji",
    matchers = { "emoji" },
    sorters = {},
  },
})

ddc_custom_patch_global("sourceOptions", {
  skkeleton = {
    mark = "SKK",
    matchers = {},
    sorters = {},
    isVolatile = true,
  },
})

ddc_custom_patch_global("sourceOptions", {
  _ = {
    -- matchers = { "matcher_head" },
    -- sorters = { "sorter_rank" },

    matchers = { "matcher_fuzzy" },
    sorters = { "sorter_fuzzy" },
    converters = { "converter_fuzzy" },
    keywordPattern = "[a-zA-Z_:]\\w*",
  },
  -- around = { mark = "around" },
})

vim.fn["ddc#custom#patch_filetype"]({ "ps1", "dosbatch", "autohotkey", "registry" }, {
  sourceOptions = {
    -- file = {
    --   forceCompletionPattern = [[\S\\\S*]],
    -- },
  },
  sourceParams = {
    -- file = {
    --   mode = "win32",
    -- },
  },
})

-- ddc_custom_patch_global("sourceParams", {
-- 	["nvim-lsp"] = { kindLabels = { Class = "c" } },
-- })

-- vim.fn["ddc#enable_terminal_completion"]()
vim.fn["ddc#enable"]()

vim.cmd([[
inoremap <expr> <TAB>
	\ pumvisible() ? '<C-n>' :
	\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
	\ '<TAB>' : ddc#map#manual_complete()
]])

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function(event)
    vim.keymap.set("i", "<CR>", function()
      if vim.fn.pumvisible() == 1 then
        return "<C-y>"
      else
        return "<CR>"
      end
    end, { expr = true })
  end,
})
