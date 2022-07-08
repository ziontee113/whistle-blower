local M = {}
local api = vim.api

-- required functions
local utils_extmarks = require("whistle-blower.utils.extmarks")
local utils_viewport = require("whistle-blower.utils.viewport")
local utils_buf_set_text = require("whistle-blower.utils.buf_set_text")
local utils_syntax_format_test = require("whistle-blower.utils.syntax-format-test")
local utils_super_idol = require("whistle-blower.utils.super-idol")
local utils_field_testing = require("whistle-blower.utils.field-testing")

local experiments_in_screen_jumping = require("whistle-blower.experiments.jump-in-screen")

-- keymaps for testing

-- vim.keymap.set("n", "<F24><F24>h", function()
-- 	utils_extmarks.test_extmark()
-- end, { noremap = true, silent = true })
-- vim.keymap.set("n", "<F24><F24>j", function()
-- 	utils_buf_set_text.set_text_test()
-- end, { noremap = true, silent = true })
-- vim.keymap.set("n", "<F24><F24>k", function()
-- 	utils_syntax_format_test.syntax_format_test()
-- end, { noremap = true, silent = true })

return M
