local M = {}
local api = vim.api
local fn = vim.fn

local function jump_in_screen()
	local scrolloff = fn.eval("&l:scrolloff")
	vim.cmd("noautocmd setlocal scrolloff=0")

	local pos = fn.getpos(".")
	vim.cmd("noautocmd keepjumps normal! H")

	local top = fn.line(".")
	vim.cmd("noautocmd keepjumps normal! L")

	local bottom = fn.line(".")

	fn.setpos(".", pos)
	vim.cmd("noautocmd setlocal scrolloff=" .. scrolloff)

	vim.pretty_print(top, bottom)
end

vim.keymap.set("n", "<F24><F24>j", function()
	jump_in_screen()
end, { noremap = true, silent = true })

return M
