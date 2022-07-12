---@diagnostic disable: missing-parameter, undefined-global
local M = {}
local api = vim.api
local fn = vim.fn
local ts_utils = require("nvim-treesitter.ts_utils")

local ns = api.nvim_create_namespace("Field Marking")

local last_kind_type = { kind = nil, type = nil }

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
local function get_nodes_in_array(root) --{{{
	local ts = vim.treesitter
	local parser = ts.get_parser(0)
	local trees = parser:parse()

	if not root then
		root = trees[1]:root()
	end

	local nodes = {}

	recursive_child_iter(root, nodes)

	return nodes
end --}}}

-- marks related functions
local function delete_all_local_marks() --{{{
	for i = 97, 122 do -- from 'a' to 'z'
		api.nvim_buf_del_mark(0, vim.fn.nr2char(i))
	end
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
		if top <= range[1] + 1 and bottom >= range[1] + 1 then
			table.insert(filtered_results, range)
		end
	end

	return filtered_results
end --}}}
local function filter_closed_folds(ranges, first_line_of_fold) --{{{
	local filtered_results = {}

	for _, range in ipairs(ranges) do
		if fn.foldclosed(range[1] + 1) == -1 then -- if not in fold or fold not closed (standard case)
			table.insert(filtered_results, range)
		else
			if first_line_of_fold and fn.foldclosed(range[1] + 1) == range[1] + 1 then -- ufo case
				table.insert(filtered_results, range)
			end
		end
	end

	return filtered_results
end --}}}

-- node related functions
local function get_nodes(node_types, root, push_table) --{{{
	local nodes = {}

	if type(node_types) == "string" then
		node_types = { node_types }
	end

	for _, node_type in ipairs(node_types) do
		for _, node in ipairs(get_nodes_in_array(root)) do
			if node:type() == node_type then
				table.insert(nodes, node)
			end
		end
	end

	if push_table then
		for _, node in ipairs(nodes) do
			table.insert(push_table, node)
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
local function get_fields(field_names, root, push_table) --{{{
	local fields = {}

	if type(field_names) == "string" then
		field_names = { field_names }
	end

	for _, value in ipairs(get_nodes_in_array(root)) do -- loop through all nodes
		for _, name in ipairs(field_names) do
			local nodes = value:parent():field(name)

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
	end

	if push_table then
		for _, field in ipairs(fields) do
			table.insert(push_table, field)
		end
	end

	return fields
end --}}}
local function get_fields_ranges(field_name) --{{{
	local ranges = {}

	for _, node in ipairs(get_fields(field_name)) do
		local range = table.pack(node:range())
		table.insert(ranges, range)
	end

	return ranges
end --}}}

-- range related functions
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
local function range_processing(ranges, opts) --{{{
	ranges = filter_in_viewport(ranges)

	if opts and opts.fold_filter then
		ranges = filter_closed_folds(ranges, opts.fold_filter)
	else
		ranges = filter_closed_folds(ranges)
	end

	ranges = sort_ranges(ranges)

	return ranges
end --}}}

local function highlight_node(node, hl_group) --{{{
	if node then
		local range = table.pack(node:range())
		api.nvim_buf_add_highlight(0, ns, hl_group or "STS_Highlight", range[1], range[2], range[4])
	end
end --}}}

-- ancestor & descendants related functions
local function find_ancestor_node_or_field(opts) --{{{
	local node = ts_utils.get_node_at_cursor(0)
	local parent = node:parent()
	local result

	if opts.kind == "node" then
		while parent do
			if node:type() == opts.type then
				result = node
				break
			else
				node = parent
				parent = node:parent()
			end
		end
	elseif opts.kind == "field" then
		while parent do
			local fields = parent:field(opts.type)

			if #fields > 0 then
				for _, field in ipairs(fields) do
					if node == field then
						result = field
						break
					end
				end
				break
			end

			node = parent
			parent = node:parent()
		end
	end

	return result
end --}}}
local function find_descendants_of_node(opts, root) --{{{
	local results = {}

	if opts.descendants then
		for _, item in ipairs(opts.descendants) do
			if item.kind == "field" then
				get_fields(item.type, root, results)
			elseif item.kind == "node" then
				get_nodes(item.type, root, results)
			end
		end
	end

	return results
end --}}}
local function find_descendants_of_closest_anscestor(opts)
	local ancestor = find_ancestor_node_or_field(opts)
	local descendants = find_descendants_of_node(opts, ancestor)

	if descendants then
		for _, node in ipairs(descendants) do
			highlight_node(node)
		end
	end

	return descendants
end

-- There is a fundamental flaw with our current system --
-- Now we have to refactor our entire code base to allow --
-- Both node & fields options --

-- jump functions
function M.target_index_handling(ranges, opts) --{{{
	local cur_line = api.nvim_win_get_cursor(0)[1]

	local target_index
	if opts.index then
		if opts.index > 0 and opts.index <= #ranges then
			target_index = opts.index
		end
	else
		if #ranges > 0 then
			if opts.jump_loop then
				target_index = opts.next and 1 or #ranges
			end

			if opts.next then
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
		end
	end

	return target_index
end --}}}
local function jump_based_on_opts_and_ranges(ranges, opts) --{{{
	local target_index = M.target_index_handling(ranges, opts)

	if target_index then
		last_kind_type = { kind = opts.kind, type = opts.type }

		api.nvim_win_set_cursor(0, { ranges[target_index][1] + 1, ranges[target_index][2] })
	end

	return ranges, target_index
end --}}}

function M.jump_ranges_handling(opts) --{{{
	local ranges

	if opts.kind == "index" and last_kind_type.kind ~= nil then
		opts.kind = last_kind_type.kind
		opts.type = last_kind_type.type
	end

	if opts.kind == "node" then
		ranges = get_nodes_ranges(opts.type)
	elseif opts.kind == "field" then
		ranges = get_fields_ranges(opts.type)
	end

	return range_processing(ranges, opts.fold_filter or false)
end --}}}
function M.jump_to_node_or_field(opts) --{{{
	if opts.kind == nil then
		return
	end

	if opts.kind == "index" then
		if last_kind_type.kind == nil then
			return
		end
	end

	local ranges = M.jump_ranges_handling(opts)

	return jump_based_on_opts_and_ranges(ranges, opts)
end --}}}

-- temporary keymaps
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<F24><F24>c", function() --{{{
	delete_all_local_marks()
	api.nvim_buf_clear_namespace(0, ns, 0, -1)
end, opts) --}}}
vim.keymap.set("n", "<F24><F24>j", function() --{{{
	delete_all_local_marks()

	api.nvim_buf_clear_namespace(0, ns, 0, -1)
	highlight_all_nodes({ "function_declaration", "function_definition" })
end, opts) --}}}
vim.keymap.set("n", "<F24><F24>k", function() --{{{
	delete_all_local_marks()

	api.nvim_buf_clear_namespace(0, ns, 0, -1)
	highlight_all_fields("condition")
	-- highlight_all_fields("local_declaration")
end, opts) --}}}
vim.keymap.set("n", "<F24><F24>p", function()
	find_descendants_of_closest_anscestor({
		kind = "field",
		type = "condition",
		descendants = {
			{ kind = "field", type = "left" },
			{ kind = "field", type = "right" },
		},
	})
end, { noremap = true, silent = true })
vim.keymap.set("n", "<F24><F24>o", function()
	find_ancestor_node_or_field({
		kind = "node",
		type = "if_statement",
	})
end, { noremap = true, silent = true })

vim.keymap.set("n", "  x", function() --{{{
	local cmd = [[
cvlc ~/Sound/all_00299.wav --gain=0.35 --play-and-exit
]]
	fn.jobstart(cmd)
end, { noremap = true, silent = true }) --}}}

--------------------------------------

return M

-- vim: foldmethod=marker foldmarker={{{,}}} foldlevel=0
