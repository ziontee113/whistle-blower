---@diagnostic disable: missing-parameter, undefined-global
local M = {}
local api = vim.api

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

-- marks related functions
local function delete_all_local_marks()
	for i = 97, 122 do -- from 'a' to 'z'
		api.nvim_buf_del_mark(0, vim.fn.nr2char(i))
	end
end

local function mark_all_fields(field) --{{{
	local nodes = get_nodes_in_array()

	local start_char_index = 97
	local hash_table = {}

	delete_all_local_marks()

	local last_field_match = { -1, -1, -1, -1 }
	for _, value in ipairs(nodes) do -- loop through all nodes
		local variable = value:parent():field(field)

		if #variable > 0 then
			local start_row, start_col, end_row, end_col = variable[1]:range()
			local range = { start_row, start_col, end_row, end_col }

			for index, _ in ipairs(range) do
				if range[index] ~= last_field_match[index] then
					last_field_match = range

					local continue = true
					for _, hash_value in ipairs(hash_table) do
						if hash_value[1] == range[1] and hash_value[2] == range[2] then
							continue = false
							break
						end
					end

					if continue then
						api.nvim_buf_set_mark(0, vim.fn.nr2char(start_char_index), range[1] + 1, range[2], {})
						start_char_index = start_char_index + 1
						table.insert(hash_table, { range[1], range[2] })
					end
				end
			end
		end
	end
end --}}}

-- temporaty keymaps
vim.keymap.set("n", "<F24><F24>l", function() --{{{
	mark_all_fields("condition")
end, { noremap = true, silent = true }) --}}}

--------------------------------------

return M
