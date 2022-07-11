local ls = require("luasnip") --{{{ Boilerplate
local s = ls.s
local i = ls.i
local t = ls.t

local d = ls.dynamic_node
local c = ls.choice_node
local f = ls.function_node
local sn = ls.snippet_node

local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep --}}}

-- Start Creating Snippets --

local testSnip1 = s("testSnip1", t("hello venus"))
local testSnip2 = s("testSnip2", t("hello from mercury"))

local if_statement = s( -- if statement
	{ trig = "if_statement", hidden = true },
	fmt(
		[[
{}if {} then
  {}
end
]],
		{
			i(1),
			i(2, "condition"),
			i(3, "-- TODO"),
		}
	)
)

local for_loop = s( -- for loop
	"for_loop",
	fmt(
		[[
f{}or _, value in ipairs(table) do
  -- TODO:
end
]],
		{
			i(1, ""),
		}
	)
)

-- End Creating Snippets --

return {
	["testSnip1"] = testSnip1,
	["testSnip2"] = testSnip2,
	["if_statement"] = if_statement,
	["for_loop"] = for_loop,
}

-- vim: foldmethod=marker foldmarker={{{,}}} foldlevel=0
