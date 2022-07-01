local M = {}
local api = vim.api

local test_extmark_fn = require("whistle-blower.utils.extmarks").test_extmark

vim.keymap.set("n", "<F24><F24>h", function()
	test_extmark_fn()
end, { noremap = true, silent = true })

return M
