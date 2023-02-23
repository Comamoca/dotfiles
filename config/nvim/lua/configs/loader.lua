local split = require("utils/split").split
local pathlib = require("utils/path")

local function load(name)
	local p = pathlib.new(name)
	-- print(p:Parent().."/"..p:FileName())
	-- print(p:Parent().."/"..p:NoSuffix())
	require(p:Parent() .. "/" .. p:NoSufix())
end

local function loadConf()
	local filelist = vim.fn.glob(vim.fn.expand("~/.config/nvim/lua/configs") .. "**/*.lua")
	local splitted = split(filelist, "\n")

	for i, name in ipairs(splitted) do
		load(name)
	end
end

return {
	loadConf = loadConf,
}
