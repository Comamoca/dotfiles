vim.api.nvim_create_user_command("Source", "source $MYVIMRC", {})
vim.api.nvim_create_user_command("Config", "e $MYVIMRC", {})
-- vim.api.nvim_create_user_command(
-- 	"Configs",
-- 	"call ddu#start({'sources': [{'name': 'file_rec', 'params': {'path': expand('~/.config/nvim/configs')}}]})",
-- 	{}
-- )
-- vim.api.nvim_create_user_command("Configs", 'call v:lua.Open("~/.config/nvim/lua/configs")', {})
vim.api.nvim_create_user_command("Configs", 'lua require("comatools/fzf").configs()', {})
vim.api.nvim_create_user_command("ComaTools", 'lua require("comatools/fzf").comatools()', {})
vim.api.nvim_create_user_command("Plugs", 'call ConfigsRec("~/.config/nvim/plugs/")', {})
vim.api.nvim_create_user_command("Dein", 'call v:lua.Open("~/.config/nvim/dein.toml")', {})
vim.api.nvim_create_user_command("Lazy", 'call v:lua.Open("~/.config/nvim/dein_lazy.toml")', {})
vim.api.nvim_create_user_command("DduToml", 'call v:lua.Open("~/.config/nvim/ddu.toml")', {})
vim.api.nvim_create_user_command("Lsp", 'call v:lua.Open("~/.config/nvim/lsp.toml")', {})
vim.api.nvim_create_user_command("Ft", 'call v:lua.Open("~/.config/nvim/ft.toml")', {})
vim.api.nvim_create_user_command("Dap", 'call v:lua.Open("~/.config/nvim/dap.toml")', {})

vim.api.nvim_create_user_command("ConfigsLinux", "call ConfigsRec('~/.config/', 'directory_rec')", {})
vim.api.nvim_create_user_command("Todo", "e ~/todo.md", {})

vim.api.nvim_create_user_command("ConfigWezterm", "e /mnt/c/Users/Coma/.config/wezterm/wezterm.lua", {})

vim.api.nvim_create_user_command("DeinInstall", "call dein#install()", {})
vim.api.nvim_create_user_command("DeinReCache", "call dein#recache_runtimepath()", {})
vim.api.nvim_create_user_command("DeinUpdate", "call dein#update()", {})

vim.api.nvim_create_user_command("ConfigFish", "e ~/.config/fish/config.fish", {})
vim.api.nvim_create_user_command("FishFunctions", "e ~/.config/fish/functions", {})
vim.api.nvim_create_user_command("Lualine", ": lua require('lualine').setup()", {})

vim.api.nvim_create_user_command("Snippets", ":e ~/.config/nvim/luasnip/", {})

vim.api.nvim_create_user_command("DapToggle", ':lua require("dapui").toggle()<CR>', {})

function Open(path)
	local file = vim.fn.expand(path)
	vim.cmd(":e " .. file)
end

function launchCmus()
	vim.cmd(":terminal cmus")
end
