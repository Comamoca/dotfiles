local ls = require("luasnip")

local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")

local function block(word)
	return {
		t(word .. " "),
		i(1),
		t(" {"),
		i(0),
		t({ "", "}" }),
	}
end

local function branch(word)
	return s(word, {
		t(word .. " "),
		i(1),
		t(" {"),
		i(0),
		t({ "", "}" }),
	})
end

return {
	s("println", {
		t("println("),
		i(0),
		t(")"),
	}),
	s("print", {
		t("print("),
		i(0),
		t(")"),
	}),
	s("eprint", {
		t("eprint("),
		i(0),
		t(")"),
	}),
	s("eprintln", {
		t("eprintln("),
		i(0),
		t(")"),
	}),
	s("isatty", {
		t("isatty("),
		i(0),
		t(")"),
	}),
	s("input", {
		t("input("),
		i(0),
		t(")"),
	}),
	s("lines", {
		t("lines("),
		i(0),
		t(")"),
	}),
	s("trim_end", {
		t("trim_end()"),
		i(0),
	}),
	s("trim_start", {
		t("trim_start()"),
		i(0),
	}),
	s("trim", {
		t("trim()"),
		i(0),
	}),
	s("trim_prefix", {
		t("trim_prefix("),
		i(0),
		t(")"),
	}),
	s("contains", {
		t("contains("),
		i(0),
		t(")"),
	}),
	s("len", {
		t("len("),
		i(0),
		t(")"),
	}),
	s("join", {
		t("join("),
		i(0),
		t(")"),
	}),
	s("namespace", {
		t("namespace "),
		i(1),
		t("{"),
		i(0),
		t({ "", "}" }),
	}),
	s("test", {
		t({ "#[test]", "fn " }),
		i(1),
		t("()"),
		t(" {"),
		i(0),
		t({ "", "}" }),
	}),
	s("fn", {
		t("fn "),
		i(1),
		t("()"),
		t(" {"),
		i(0),
		t({ "", "}" }),
	}),
	s("for", {
		t("for "),
		i(1),
		t(" {"),
		i(0),
		t({ "", "}" }),
	}),
	-- s("if", {
	-- 	t("if "),
	-- 	i(1),
	-- 	t(" {"),
	-- 	i(0),
	-- 	t({ "", "}" }),
	-- }),
	branch("if"),
	branch("else if"),
	branch("else"),
	-- s("println", {
	-- 	t("println("),
	-- 	i(0),
	-- 	t(")"),
	-- }),
}
