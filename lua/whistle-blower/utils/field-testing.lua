---@diagnostic disable: missing-parameter, undefined-global
local M = {}
local api = vim.api

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
	local start_row, start_col, end_row, end_col = node:range()
	local range = { start_row, start_col, end_row, end_col }

	return range
end --}}}

-- marks related functions
local function delete_all_local_marks() --{{{
	for i = 97, 122 do -- from 'a' to 'z'
		api.nvim_buf_del_mark(0, vim.fn.nr2char(i))
	end
end --}}}

-- field related functions
local function get_fields(field_name) --{{{
	local nodes = get_nodes_in_array()

	local fields = {}

	for _, value in ipairs(nodes) do -- loop through all nodes
		local node = value:parent():field(field_name)

		if #node > 0 then
			local continue = true
			for _, field in ipairs(fields) do
				if field == node[1] then
					continue = false
				end
			end

			if continue then
				table.insert(fields, node[1])
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

-- highlight functions
local function highlight_all_fields(field_name) --{{{
	for _, range in ipairs(get_fields(field_name)) do
		api.nvim_buf_add_highlight(0, ns, "GruvboxBlueSign", range[1], range[2], range[4])
	end
end --}}}

-- temporaty keymaps
vim.keymap.set("n", "<F24><F24>l", function() --{{{
	delete_all_local_marks()

	api.nvim_buf_clear_namespace(0, ns, 0, -1)
	highlight_all_fields("condition")
	-- highlight_all_fields("local_declaration")
end, { noremap = true, silent = true }) --}}}

--------------------------------------

return M
