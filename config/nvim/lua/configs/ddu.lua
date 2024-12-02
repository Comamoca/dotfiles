-- require("configs/ddu")

local keymap = vim.keymap.set
local ddu_custom_patch_global = vim.fn["ddu#custom#patch_global"]
local ddu_custom_action = vim.fn["ddu#custom#action"]
local keymap_opt = { buffer = true, silent = true }

local columns = vim.opt.columns:get()
local width, col = math.floor(columns * 0.8), math.floor(columns * 0.12)

ddu_custom_patch_global({
  ui = "ff",
  sources = {
    {
      -- default source
      name = "file_external",
      params = {
        -- ignoredDirectories = { ".venv", ".git", "node_modules", "vendor", ".next" },
      },
    },
  },
  sourceOptions = {
    _ = {
      -- matchers = { "matcher_substring" },
      matchers = { "merge" },
      sorters = { "sorter_fzf" },
    },
    spotify = {
      matchers = { "matcher_kensaku" },
    },
    file_external = {
      matchers = { "matcher_kensaku" },
    }
  },
  sourceParams = {
    file_external = {
      cmd = { vim.fn.expand("~/.nix-profile/bin/fd"), ".", "-H", "-E", ".git", "-t", "f" },
    },
    rg = {
      args = { "--column", "--no-heading", "--color", "never" },
      inputType = "migemo",
    },
  },
  filterParams = {
    merge = {
      filters = {
        { name = "matcher_kensaku", weight = 1.0 },
        { name = "matcher_fzf", weight = 1.0 },
      },
    },
    matcher_fzf = {
      highlightMatched = "Search",
    },
    matcher_kensaku = {
      highlightMatched = "Search",
    },
  },
  kindOptions = {
    _ = {
      defaultAction = "open",
    },
    action = {
      defaultAction = "do",
    },
    ["custom-list"] = {
      defaultAction = "callback",
    },
    memos = {
      defaultAction = "echo",
    },
    spotify = {
      defaultAction = "play",
    },
    lsp_codeAction = {
      defaultAction = "apply",
    },
    source = {
      defaultAction = "execute",
    },
    deol = {
      defaultAction = "switch",
      -- defaultAction = "new"
    },
  },
  uiParams = {
    ff = {
      prompt = "> ",
      -- split = "floating",
      previewFloating = false,
      previewSplit = "vertical",
      previewFloatingBorder = "single",
      previewWidth = math.floor((width / 6) * 3), -- 2/5
      previewHeight = col,
      autoAction = {
        name = "preview",
      },
    },
  },
})

ddu_custom_patch_global("sourceOptions", {
  spotify = {
    matchers = { "matcher_kensaku" },
  },
})

-- ddu_custom_patch_global('filterParams', {
-- 	matcher_kensaku = {
-- 		highlightMatched = 'Search',
-- 	},
-- })

-- ddu#custom#action('source', 'buffer', 'bdelete', function('s:deleteBuffer'))
-- ddu_custom_action('ui', 'ff', 'buf_delete', function (args)

ddu_custom_action("ui", "ff", "custom:buf_delete", function()
  -- ddu_custom_action('kind', 'file', 'custom:buf_delete', function (args)
  -- local items = args.items
  -- local items = vim.fn["ddu#ui#get_items"]()
  local item = vim.fn["ddu#ui#get_item"]()

  local action = item["action"]
  -- vim.print(action)

  local bufnr = action["bufNr"]

  vim.cmd("bd " .. bufnr)

  return 1
end)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "ddu-ff",
  callback = function()
    keymap("n", "<CR>", "<Cmd>call ddu#ui#do_action('itemAction')<CR>", keymap_opt)
    keymap("n", "<Space>", "<Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>", keymap_opt)
    keymap("n", "i", "<Cmd>call ddu#ui#do_action('openFilterWindow')<CR>", keymap_opt)
    keymap("n", "q", "<Cmd>call ddu#ui#do_action('quit')<CR>", keymap_opt)

    ------

    local item = vim.fn["ddu#ui#get_item"]()
    local items = vim.fn["ddu#ui#get_items"]()

    local source = vim.fn["ddu#custom#get_current"]()["sources"]

    -- enable keymap when source is buffer.
    if #source == 1 and source[1]["name"] == "buffer" then
      -- keymap.del("n", "dd")
      -- if items == 1 then
      --  local bufnr = items[1]["action"]["bufNr"]
      --  print(bufnr)
      --  -- print(vim.fn["ddu#ui#get_item"]())
      -- end

      keymap("n", "d", "<Cmd>call ddu#ui#do_action('custom:buf_delete')<CR>", keymap_opt)
    end

    vim.api.nvim_create_autocmd("CursorMoved", {
      pattern = "*",
      callback = function()
        vim.fn["ddu#ui#do_action"]("preview")
      end,
    })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "ddu-ff-filter",
  callback = function()
    keymap("i", "<C-c>", "<Esc><Cmd>close<CR>", keymap_opt)
    keymap("i", "<CR>", "<Esc><Cmd>close<CR>", keymap_opt)
    keymap("n", "<CR>", "<Cmd>close<CR>", keymap_opt)
    keymap("n", "q", "<Cmd>call ddu#ui#do_action('quit')<CR>", keymap_opt)
  end,
})
