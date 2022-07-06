local api = vim.api

-- kemap shorthands
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- require STS and Hydra
local sts = require("syntax-tree-surfer")
local Hydra = require("hydra")

-- require LuaSnip
local ls = require("luasnip")
local expand = ls.snip_expand

-- require hydra-snippets
local snippets = require("whistle-blower.hydra-snippets.all")

-- test Hydra with LuaSnip
local test_hydra = Hydra({
	name = "Test Hydra",
	mode = { "n" },
	body = "<F99>xxx", -- testing non exist Hydra body
	config = {
		color = "pink",
	},
	heads = { --{{{
		{
			"a",
			function()
				vim.cmd("norm! O")

				local key = vim.api.nvim_replace_termcodes("O", true, true, true)
				vim.api.nvim_feedkeys(key, "n", false)

				vim.schedule(function()
					expand(snippets["if_statement"])

					vim.schedule(function()
						key = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
						vim.api.nvim_feedkeys(key, "i", false)
					end)
				end)
			end,
		},
		{
			"d",
			function()
				local curline = api.nvim_win_get_cursor(0)[1]

				---> get parent node indent

				api.nvim_buf_set_lines(0, curline - 1, curline - 1, false, { string.rep(" ", 12), "" })

				--> Find a way to get the correct indent
				api.nvim_win_set_cursor(0, { curline, 8 })

				expand(snippets["for_loop"])
				vim.schedule(function()
					local key = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
					vim.api.nvim_feedkeys(key, "i", false)
				end)
			end,
			{ nowait = true },
		},
		{
			"w",
			function()
				vim.cmd([[normal! O]])

				vim.schedule(function()
					local key = vim.api.nvim_replace_termcodes("O", true, true, true)
					vim.api.nvim_feedkeys(key, "n", false)
				end)
			end,
		},
		{
			"s",
			function()
				N("hello venus")
			end,
			{ exit = true },
		},

		{ "q", nil, { exit = true, nowait = true } },
		{ "<Esc>", nil, { exit = true, nowait = true } },
	}, --}}}
})

-- STS keymaps{{{
keymap("n", "<Leader>O", function() -- master node
	sts.go_to_node_and_execute_commands(sts.get_master_node(), false, {
		function()
			vim.cmd([[normal! O]])

			local key = vim.api.nvim_replace_termcodes("O", true, true, true)
			vim.api.nvim_feedkeys(key, "n", false)
		end,
	})
end, opts)

keymap("n", "<Leader>o", function() -- master node
	sts.go_to_node_and_execute_commands(sts.get_master_node(), true, {
		function()
			vim.cmd([[normal! o]])

			local key = vim.api.nvim_replace_termcodes("o", true, true, true)
			vim.api.nvim_feedkeys(key, "n", false)
		end,
	})
end, opts) --}}}

-- Hydra Keymaps
vim.keymap.set("n", "<C-e>", function()
	test_hydra:activate()
end, { noremap = true, silent = true })

-- Todos
