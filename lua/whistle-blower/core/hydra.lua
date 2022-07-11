local api = vim.api
local jump = require("whistle-blower.core.virt-jump")

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
local old_scrolloff = 0
local test_hydra = Hydra({
	name = "Test Hydra",
	mode = { "n" },
	body = "<F99>xxx", -- testing non exist Hydra body
	config = {
		color = "pink",
		on_enter = function()
			old_scrolloff = vim.o.scrolloff
			vim.o.scrolloff = 0

			-- vim.fn.jobstart("cvlc ~/Sound/sc1_vo_loyalguard_L.wav --gain=0.15 --play-and-exit")
			vim.fn.jobstart("cvlc ~/Sound/all_00302.wav --gain=0.2 --play-and-exit")
		end,
		on_exit = function()
			vim.o.scrolloff = old_scrolloff
			vim.fn.jobstart("cvlc ~/Sound/all_00299.wav --gain=0.2 --play-and-exit")
		end,
	},
	heads = { --{{{
		{
			"1",
			function()
				jump.jump_with_virt_text({
					kind = "index",
					index = 1,
				})
			end,
			{ nowait = true },
		},

		{
			"F",
			function()
				jump.jump_with_virt_text({
					kind = "node",
					type = { "function_declaration", "function_definition" },
					jump_loop = true,
				})
				vim.fn.jobstart("cvlc ~/Sound/sc1_vo_gunslinger_L.wav --gain=0.11 --play-and-exit")
			end,
		},
		{
			"f",
			function()
				jump.jump_with_virt_text({
					kind = "node",
					type = { "function_declaration", "function_definition" },
					next = true,
					jump_loop = true,
				})
				vim.fn.jobstart("cvlc ~/Sound/sc1_vo_gunslinger_L.wav --gain=0.11 --play-and-exit")
			end,
		},

		{
			"V",
			function()
				jump.jump_with_virt_text({
					kind = "field",
					type = { "local_declaration" },
					jump_loop = true,
				})
				vim.fn.jobstart("cvlc ~/Sound/sc1_vo_loyalguard_L.wav --gain=0.11 --play-and-exit")
			end,
			{ nowait = true },
		},
		{
			"v",
			function()
				jump.jump_with_virt_text({
					kind = "field",
					type = { "local_declaration" },
					next = true,
					jump_loop = true,
				})
				vim.fn.jobstart("cvlc ~/Sound/sc1_vo_loyalguard_L.wav --gain=0.11 --play-and-exit")
			end,
			{ nowait = true },
		},

		{
			"O",
			function()
				jump.jump_with_virt_text({
					kind = "field",
					type = { "clause" },
					jump_loop = true,
				})
				vim.fn.jobstart("cvlc ~/Sound/sc2_vo_swords_L.wav --gain=0.11 --play-and-exit")
			end,
		},
		{
			"o",
			function()
				jump.jump_with_virt_text({
					kind = "field",
					type = { "clause" },
					next = true,
					jump_loop = true,
				})
				vim.fn.jobstart("cvlc ~/Sound/sc2_vo_swords_L.wav --gain=0.11 --play-and-exit")
			end,
		},

		{
			"E",
			function()
				jump.jump_with_virt_text({
					kind = "node",
					type = { "else_statement" },
					jump_loop = true,
				})
			end,
		},
		{
			"e",
			function()
				jump.jump_with_virt_text({
					kind = "node",
					type = { "else_statement" },
					next = true,
					jump_loop = true,
				})

				vim.fn.jobstart("cvlc ~/Sound/sc2_vo_trick_L.wav --gain=0.15 --play-and-exit")
			end,
		},

		{
			"I",
			function()
				jump.jump_with_virt_text({
					kind = "field",
					type = { "condition" },
					jump_loop = true,
				})

				vim.fn.jobstart("cvlc ~/Sound/sc2_vo_trick_L.wav --gain=0.15 --play-and-exit")
			end,
		},
		{
			"i",
			function()
				jump.jump_with_virt_text({
					kind = "field",
					type = { "condition" },
					next = true,
					jump_loop = true,
				})

				vim.fn.jobstart("cvlc ~/Sound/sc2_vo_trick_L.wav --gain=0.15 --play-and-exit")
			end,
		},

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

-- vim: foldmethod=marker foldmarker={{{,}}} foldlevel=0
