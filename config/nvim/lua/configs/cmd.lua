vim.api.nvim_create_user_command("Config", "e $MYVIMRC", {})
vim.api.nvim_create_user_command("DduToml", "e $MYVIMRC", {})
vim.api.nvim_create_user_command("DdcToml", "", {})
-- vim.api.nvim_create_user_command("DduToml", "e $MYVIMRC", {})

vim.api.nvim_create_user_command("Ddu", function(args)
  local subcmd = args.args
  print(subcmd)
  vim.fn["ddu#start"]({ sources = {{ name = subcmd }} })
end, { nargs = 1 })
