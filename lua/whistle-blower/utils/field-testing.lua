---@diagnostic disable: missing-parameter
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

	local current_buffer = vim.api.nvim_get_current_buf()
	local nodes = {}

	recursive_child_iter(root, nodes)

	N(#nodes)

	return nodes
end

get_nodes_in_array()

--------------------------------------

return M
