local M = {}
local api = vim.api

M.set_text_test = function()
	api.nvim_buf_set_text(0, 1, 0, 1, 5, { "de xiao rong" })
end

return M
