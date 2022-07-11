local M = {}
local api = vim.api

local jump = require("whistle-blower.core.jump")

M.jump_with_virt_text = function(opts)
	jump.jump_to_node_or_field(opts)
end

-- temporary keymaps
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<F24><F24>l", function() --{{{
	M.jump_with_virt_text({
		kind = "field",
		type = "condition",
		next = true,
	})
end, opts) --}}}
vim.keymap.set("n", "<F24><F24>h", function() --{{{
	M.jump_with_virt_text({
		kind = "field",
		type = "condition",
	})
end, opts) --}}}

return M
