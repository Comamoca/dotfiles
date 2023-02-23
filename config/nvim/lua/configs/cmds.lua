vim.api.nvim_create_user_command("Source", "source $MYVIMRC", {})
vim.api.nvim_create_user_command("Config", "e $MYVIMRC", {})
vim.api.nvim_create_user_command(
	"Configs",
	"call ddu#start({'sources': [{'name': 'file_rec', 'params': {'path': expand('~/.config/nvim/configs')}}]})",
	{}
)
vim.api.nvim_create_user_command("Configs", 'call v:lua.Open("~/.config/nvim/lua/configs")', {})
vim.api.nvim_create_user_command("Plugs", 'call ConfigsRec("~/.config/nvim/plugs/")', {})
vim.api.nvim_create_user_command("Dein", 'call v:lua.Open("~/.config/nvim/dein.toml")', {})
vim.api.nvim_create_user_command("Lazy", 'call v:lua.Open("~/.config/nvim/dein_lazy.toml")', {})
vim.api.nvim_create_user_command("DduToml", 'call v:lua.Open("~/.config/nvim/ddu.toml")', {})
vim.api.nvim_create_user_command("Lsp", 'call v:lua.Open("~/.config/nvim/lsp.toml")', {})

vim.api.nvim_create_user_command("ConfigsLinux", "call ConfigsRec('~/.config/', 'directory_rec')", {})
vim.api.nvim_create_user_command("ConfigsLinux", "Defx ~/.config", {})
vim.api.nvim_create_user_command("Plugins", "e ~/.config/nvim/dein.toml", {})
vim.api.nvim_create_user_command("PluginLazy", "e ~/.config/nvim/dein_lazy.toml", {})
vim.api.nvim_create_user_command("ConfigsDefx ", "Defx ~/.config/nvim/configs", {})
vim.api.nvim_create_user_command("Org", "Defx ~/org", {})
vim.api.nvim_create_user_command("Todo", "e ~/todo.md", {})
vim.api.nvim_create_user_command("ConfigLua", "e ~/.config/nvim/lua", {})

vim.api.nvim_create_user_command("ConfigWezterm", "e /mnt/c/Users/Coma/.config/wezterm/wezterm.lua", {})

vim.api.nvim_create_user_command("DeinInstall", "call dein#install()", {})
vim.api.nvim_create_user_command("DeinReCache", "call dein#recache_runtimepath()", {})

vim.api.nvim_create_user_command("ConfigFish", "e ~/.config/fish/config.fish", {})
vim.api.nvim_create_user_command("FishFunctions", "e ~/.config/fish/functions", {})

function Open(path)
	local file = vim.fn.expand(path)
	vim.cmd(":e " .. file)
end

function launchCmus()
	vim.cmd(":terminal cmus")
end
