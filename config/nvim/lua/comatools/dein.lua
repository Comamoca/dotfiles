local function add(package)
	vim.call("dein#add", package)
end

-- local function load_toml(table)
-- 	for _, toml in ipairs(table) do
-- 		vim.call("dein#load_toml", toml.path, { lazy = toml.lazy })
-- 	end
-- end

local function load_toml(table)
	for _, toml in ipairs(table) do
		-- print(string.format("installing %s lazy = %d", toml.path, toml.lazy))
		vim.call("dein#load_toml", toml.path, { lazy = toml.lazy })
	end
end

local function prelude(callback)
	-- dein.vim loading script
	local dein_dir = vim.env.HOME .. "/.cache/dein"
	local dein_repo_dir = dein_dir .. "/repos/github.com/Shougo/dein.vim"

	if not string.match(vim.o.runtimepath, "/dein.vim") then
		if vim.fn.isdirectory(dein_repo_dir) ~= 1 then
			os.execute("git clone https://github.com/Shougo/dein.vim " .. dein_repo_dir)
		end
		vim.o.runtimepath = dein_repo_dir .. "," .. vim.o.runtimepath

		begin = function(callback) end
	end

	if vim.call("dein#load_state", dein_dir) == 1 then
		vim.call("dein#begin", dein_dir)

		callback()

		vim.call("dein#end")
		vim.call("dein#save_state")
	end
end

return {
	add = add,
	load_toml = load_toml,
	prelude = prelude,
}
