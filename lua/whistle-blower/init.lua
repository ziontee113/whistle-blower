local M = {}
local api = vim.api

-- required functions
local utils_extmarks = require("whistle-blower.utils.extmarks")
local utils_viewport = require("whistle-blower.utils.viewport")

-- keymaps for testing
vim.keymap.set("n", "<F24><F24>h", function()
	utils_extmarks.test_extmark()
end, { noremap = true, silent = true })

return M
