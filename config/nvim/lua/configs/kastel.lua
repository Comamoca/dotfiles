vim.api.nvim_create_autocmd("FileType", {
  pattern = "gleam",
  callback = function()
    vim.b.symbol_list = { "->", "|>", "<>", "<-", "_ ->" }
  end,
})

function _G.symbol_cmp()
  local triggers = vim.fn.split("hjklnmfdsavcuiorew", [[\zs]])

  local comp_list = vim.fn.map(vim.fn.copy(vim.b.symbol_list), function(i, v)
    return { word = v, menu = vim.fn.get(triggers, i, "") }
  end)

  -- vim.on_key(symbol_select)

  vim.fn.complete(vim.fn.col(".") - 1, comp_list)
end

function _G.symbol_select(key, typed)
  local items = vim.fn.complete_info({ "items" }).items
  local idx = vim.fn.indexof(items, function(_, v)
    return vim.fn.get(v, "menu", "") == key
  end)

  if idx >= 0 then
    vim.print(idx)
    -- vim.fn.feedkeys("i<BS>" .. items[idx].word,"i")

    vim.cmd([[call feedkeys("i\<BS>" .. a:items[idx].word, "ni")]])

    -- vim.print(items[idx].word)
    return ""
  end
end

vim.keymap.set("i", ",", function()
  return vim.fn.exists("b:symbol_list") and ",<cmd>lua symbol_cmp()<cr>" or ","
end, { expr = true, noremap = true })
