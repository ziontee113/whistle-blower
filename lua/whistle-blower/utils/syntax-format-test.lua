local M = {}
local api = vim.api

local if_statement = [[
if xxx then
  yyy
end
]]

local function_statement = [[
local function xxx(xxx)
  yyy
end
]]

local function string_splitter(str)
	local lines = {}
	for s in str:gmatch("[^\r\n]+") do
		table.insert(lines, s)
	end

	return lines
end

M.syntax_format_test = function()
	local curline = api.nvim_win_get_cursor(0)[1] - 1
	api.nvim_buf_set_lines(0, curline, curline, false, string_splitter(if_statement))
end

return M
