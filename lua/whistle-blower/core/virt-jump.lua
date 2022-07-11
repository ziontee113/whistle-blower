local M = {}
local api = vim.api
local fn = vim.fn
local ns = api.nvim_create_namespace("virt-jump")

local jump = require("whistle-blower.core.jump")

local function set_extmark(start_row, start_col, contents, color_group, timeout) --{{{
	if not contents then
		contents = ""
	end

	local extmark_id = api.nvim_buf_set_extmark(0, ns, start_row, start_col - 0, {
		virt_text = { { contents, color_group } },
		virt_text_pos = "overlay",
	})

	if timeout then
		local timer = vim.loop.new_timer()
		timer:start(
			timeout,
			timeout,
			vim.schedule_wrap(function()
				api.nvim_buf_del_extmark(0, ns, extmark_id)
			end)
		)
	end

	return extmark_id
end --}}}
M.jump_with_virt_text = function(opts)
	api.nvim_buf_clear_namespace(0, ns, 0, -1)

	local ranges = jump.jump_ranges_handling(opts)

	for index, range in ipairs(ranges) do
		set_extmark(range[1], range[2], tostring(index), "STS_highlight", 200)
	end

	jump.jump_to_node_or_field(opts)
end

-- temporary keymaps
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<F24><F24>l", function() --{{{
	M.jump_with_virt_text({
		kind = "field",
		type = "local_declaration",
		next = true,
	})
end, opts) --}}}
vim.keymap.set("n", "<F24><F24>h", function() --{{{
	M.jump_with_virt_text({
		kind = "field",
		type = "local_declaration",
	})
end, opts) --}}}

return M
