local function isNodejs()
	local packagejson = "package.json"

	if vim.fn.findfile(packagejson, "./") == packagejson then
		return true
	else
		return false
	end
end

local function useGyro()
	local gyroZzz = "gyro.zzz"

	if vim.fn.findfile(gyroZzz, "./") == gyroZzz then
		return true
	else
		return false
	end
end

require("runit").setup({
	js = function(file)
		if isNodejs() then
			return "node" .. file
		else
			return "deno run -A " .. file
		end
	end,
	ts = function(file)
		return "deno run -A " .. file
	end,
	mjs = function(file)
		return "node" .. file
	end,
	py = function(file)
		return "python" .. file
	end,
	go = function(file)
		return "go run" .. file
	end,
	ex = function(file)
		return "iex -S mix"
	end,
	nim = function(file)
		return "nim c -r " .. file
	end,
	md = function(file)
		return "goma p " .. file
	end,
	zig = function(file)
		-- if useGyro() then
		-- end
		return "gryo build run"
		-- else
		-- 	return "zig run" .. file
		-- end
	end,
	tsx = function(file)
		return "deno run -A " .. file
	end,
	er = function(file)
		return "erg" .. file
	end,
	rs = function(file)
		return "cargo run" .. file
	end,
	li = function(file)
		return "lic run" .. file
	end,
	html = function(file)
		return "python -m http.server"
	end,

	gleam = function(file)
		return "gleam run"
	end,
	teal = function(file)
		return "tl run" .. file
	end,
}, "Deol")

local table = {
	js = {
		run = function(file)
			if isNodejs() then
				return "node" .. file
			else
				return "deno run -A " .. file
			end
		end,
		format = function()
			if isNodejs() then
				return
			else
				return "deno fmt"
			end
		end,
	},
	ts = function()
		return "deno fmt"
	end,
	mjs = function(file)
		return "node" .. file
	end,
	py = function(file)
		return "python" .. file
	end,
	go = function(file)
		return "go run" .. file
	end,
	ex = function(file)
		return "iex -S mix"
	end,
	nim = function(file)
		return "nim c -r " .. file
	end,
	md = function(file)
		return "goma p " .. file
	end,
	zig = function(file)
		-- if useGyro() then
		-- end
		return "gryo build run"
		-- else
		-- 	return "zig run" .. file
		-- end
	end,
	tsx = function(file)
		return "deno run -A " .. file
	end,
	er = function(file)
		return "erg" .. file
	end,
	rs = function(file)
		return "cargo run" .. file
	end,
	li = function(file)
		return "lic run" .. file
	end,
	html = function(file)
		return "python -m http.server"
	end,

	gleam = function(file)
		return "gleam run"
	end,
	teal = function(file)
		return "tl run" .. file
	end,
}
