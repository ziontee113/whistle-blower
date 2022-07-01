local M = {}
local api = vim.api

local ns = api.nvim_create_namespace("whistle-blower")

local test_extmark

api.nvim_buf_clear_namespace(0, ns, 0, -1)

vim.keymap.set("n", "<F24><F24>h", function()
	local curLine = api.nvim_win_get_cursor(0)[1] - 1
	test_extmark = api.nvim_buf_set_extmark(0, ns, curLine, -1, {
		virt_text = { { "|||", "CmpItemKindClass" } },
		-- virt_text_win_col = 40,
	})
end, { noremap = true, silent = true })

return M
