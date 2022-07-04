local M = {}
local api = vim.api

-- required functions
local utils_extmarks = require("whistle-blower.utils.extmarks")
local utils_viewport = require("whistle-blower.utils.viewport")
local utils_buf_set_text = require("whistle-blower.utils.buf_set_text")

-- keymaps for testing
vim.keymap.set("n", "<F24><F24>h", function()
	utils_extmarks.test_extmark()
end, { noremap = true, silent = true })
vim.keymap.set("n", "<F24><F24>j", function()
	utils_buf_set_text.set_text_test()
end, { noremap = true, silent = true })

return M
