---@diagnostic disable: missing-parameter, undefined-global
local M = {}
local api = vim.api

--------------------------------------

local function recursive_child_iter(node, table_to_insert) --
	if node:iter_children() then
		for child, field in node:iter_children() do
			table.insert(table_to_insert, child)

			if field then
				table.insert(table_to_insert, field)
			end

			recursive_child_iter(child, table_to_insert)
		end
	end
end

local function get_nodes_in_array()
	local ts = vim.treesitter
	local parser = ts.get_parser(0)
	local trees = parser:parse()
	local root = trees[1]:root()

	local nodes = {}

	recursive_child_iter(root, nodes)

	return nodes
end

local function print_node_type_and_field()
	local nodes = get_nodes_in_array()
	vim.cmd([[messages clear]])

	local start_char_index = 97
	local hash_table = {}

	for i = start_char_index, 122 do
		api.nvim_buf_del_mark(0, vim.fn.nr2char(i))
	end

	local last_field_match = { -1, -1, -1, -1 }
	for _, value in ipairs(nodes) do
		if type(value) ~= "string" then
			local variable = value:parent():field("condition")

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
							P(range)
							api.nvim_buf_set_mark(0, vim.fn.nr2char(start_char_index), range[1] + 1, range[2], {})
							start_char_index = start_char_index + 1
							table.insert(hash_table, { range[1], range[2] })
						end
					end
				end
			end
		end
	end
end

print_node_type_and_field()

--------------------------------------

return M
