local split = require("utils/split").split
local pathlib = require("utils/path")

local function loadConf()
	local filelist = vim.fn.glob(vim.fn.expand("~/.config/nvim/lua/configs") .. "**/*.lua")
	local splitted = split(filelist, "\n")

	for i, path in ipairs(splitted) do
		local p = pathlib.new(path)
		-- print(p:Parent().."/"..p:FileName())
		-- print(p:Parent().."/"..p:NoSuffix())
		require(p:Parent() .. "/" .. p:NoSufix())
	end
end

return {
	loadConf = loadConf
}
