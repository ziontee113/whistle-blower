---@diagnostic disable: missing-parameter, undefined-global
local M = {}
local api = vim.api
local fn = vim.fn

local ns = api.nvim_create_namespace("Field Marking")

--------------------------------------

-- get nodes functions
local function recursive_child_iter(node, table_to_insert) --{{{
	if node:iter_children() then
		for child in node:iter_children() do
			table.insert(table_to_insert, child)

			recursive_child_iter(child, table_to_insert)
		end
	end
end --}}}
local function get_nodes_in_array() --{{{
	local ts = vim.treesitter
	local parser = ts.get_parser(0)
	local trees = parser:parse()
	local root = trees[1]:root()

	local nodes = {}

	recursive_child_iter(root, nodes)

	return nodes
end --}}}

local function get_range_of_node(node) --{{{
	return table.pack(node:range())
end --}}}

-- marks related functions
local function delete_all_local_marks() --{{{
	for i = 97, 122 do -- from 'a' to 'z'
		api.nvim_buf_del_mark(0, vim.fn.nr2char(i))
	end
end --}}}

-- node related functions
local function get_nodes(node_types) --{{{
	local nodes = {}

	if type(node_types) == "string" then
		node_types = { node_types }
	end

	for _, node_type in ipairs(node_types) do
		for _, node in ipairs(get_nodes_in_array()) do
			if node:type() == node_type then
				table.insert(nodes, node)
			end
		end
	end

	return nodes
end --}}}
local function get_nodes_ranges(node_types) --{{{
	local ranges = {}

	for _, node in ipairs(get_nodes(node_types)) do
		table.insert(ranges, table.pack(node:range()))
	end

	return ranges
end --}}}

-- field related functions
local function get_fields(field_name) --{{{
	local fields = {}

	for _, value in ipairs(get_nodes_in_array()) do -- loop through all nodes
		local nodes = value:parent():field(field_name)

		if #nodes > 0 then
			for _, node in ipairs(nodes) do
				local continue = true
				for _, field in ipairs(fields) do
					if field == node then
						continue = false
					end
				end

				if continue then
					table.insert(fields, node)
				end
			end
		end
	end

	return fields
end --}}}
local function get_fields_ranges(field_name) --{{{
	local ranges = {}

	for _, node in ipairs(get_fields(field_name)) do
		local range = get_range_of_node(node)
		table.insert(ranges, range)
	end

	return ranges
end --}}}
local function sort_ranges(ranges) --{{{
	local results = {}

	for _, v in pairs(ranges) do
		table.insert(results, v)
	end

	table.sort(results, function(a, b)
		return a[1] < b[1]
	end)

	return results
end --}}}

-- viewport related functions
local function get_viewport_lines_range() --{{{
	local scrolloff = fn.eval("&l:scrolloff")
	vim.cmd("noautocmd setlocal scrolloff=0")

	local pos = fn.getpos(".")
	vim.cmd("noautocmd keepjumps normal! H")

	local top = fn.line(".")
	vim.cmd("noautocmd keepjumps normal! L")

	local bottom = fn.line(".")

	fn.setpos(".", pos)
	vim.cmd("noautocmd setlocal scrolloff=" .. scrolloff)

	return top, bottom
end --}}}
local function filter_in_viewport(ranges) --{{{
	local top, bottom = get_viewport_lines_range()
	local filtered_results = {}

	for _, range in ipairs(ranges) do
		if top < range[1] and bottom > range[1] then
			table.insert(filtered_results, range)
		end
	end

	return filtered_results
end --}}}
local function filter_closed_folds(ranges) --{{{
	local filtered_results = {}

	for _, range in ipairs(ranges) do
		if fn.foldclosed(range[1]) == -1 then
			table.insert(filtered_results, range)
		end
	end

	return filtered_results
end --}}}

-- highlight functions
local function highlight_all_fields(field_name) --{{{
	for _, range in ipairs(get_fields_ranges(field_name)) do
		api.nvim_buf_add_highlight(0, ns, "GruvboxBlueSign", range[1], range[2], range[4])
	end
end --}}}

-- jump functions
M.jump_to_node = function(node_types, jump_next) --{{{
	local cur_line = api.nvim_win_get_cursor(0)[1]

	local ranges = get_nodes_ranges(node_types)

	ranges = filter_in_viewport(ranges)
	ranges = filter_closed_folds(ranges)
	ranges = sort_ranges(ranges)

	if #ranges > 0 then
		local target_index = jump_next and 1 or #ranges

		if jump_next then
			for i, range in ipairs(ranges) do
				if range[1] + 1 > cur_line then
					target_index = i
					break
				end
			end
		else
			for i = #ranges, 1, -1 do
				if ranges[i][1] + 1 < cur_line then
					target_index = i
					break
				end
			end
		end

		api.nvim_win_set_cursor(0, { ranges[target_index][1] + 1, ranges[target_index][2] })
	end
end --}}}
M.jump_to_field = function(field_names, jump_next) --{{{
	local cur_line = api.nvim_win_get_cursor(0)[1]

	if type(field_names) == "string" then
		field_names = { field_names }
	end

	local ranges = {}
	for _, field in ipairs(field_names) do
		local current_ranges = get_fields_ranges(field)
		for _, range in ipairs(current_ranges) do
			table.insert(ranges, range)
		end
	end

	ranges = filter_in_viewport(ranges)
	ranges = filter_closed_folds(ranges)
	ranges = sort_ranges(ranges)

	if #ranges > 0 then
		local target_index = jump_next and 1 or #ranges

		if jump_next then
			for i, range in ipairs(ranges) do
				if range[1] + 1 > cur_line then
					target_index = i
					break
				end
			end
		else
			for i = #ranges, 1, -1 do
				if ranges[i][1] + 1 < cur_line then
					target_index = i
					break
				end
			end
		end

		api.nvim_win_set_cursor(0, { ranges[target_index][1] + 1, ranges[target_index][2] })
	end
end --}}}

-- temporaty keymaps
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<F24><F24>c", function() --{{{
	delete_all_local_marks()
	api.nvim_buf_clear_namespace(0, ns, 0, -1)
end, opts) --}}}
vim.keymap.set("n", "<F24><F24>k", function() --{{{
	delete_all_local_marks()

	api.nvim_buf_clear_namespace(0, ns, 0, -1)
	-- highlight_all_fields("condition")
	highlight_all_fields("local_declaration")
end, opts) --}}}
vim.keymap.set("n", "<F24><F24>l", function() --{{{
	M.jump_to_field({ "condition" }, true)
end, opts) --}}}
vim.keymap.set("n", "<F24><F24>h", function() --{{{
	M.jump_to_field({ "condition" }, false)
end, opts) --}}}

--------------------------------------

return M

-- vim: foldmethod=marker foldmarker={{{,}}} foldlevel=0
