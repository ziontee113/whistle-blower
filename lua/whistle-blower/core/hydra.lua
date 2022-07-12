local api = vim.api
local jump = require("whistle-blower.core.jump")
local virt_jump = require("whistle-blower.core.virt-jump")

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
				virt_jump.jump_with_virt_text({
					kind = "index",
					index = 1,
				})
			end,
			{ nowait = true },
		},
		{
			"2",
			function()
				virt_jump.jump_with_virt_text({
					kind = "index",
					index = 2,
				})
			end,
			{ nowait = true },
		},
		{
			"3",
			function()
				virt_jump.jump_with_virt_text({
					kind = "index",
					index = 3,
				})
			end,
			{ nowait = true },
		},
		{
			"4",
			function()
				virt_jump.jump_with_virt_text({
					kind = "index",
					index = 4,
				})
			end,
			{ nowait = true },
		},
		{
			"5",
			function()
				virt_jump.jump_with_virt_text({
					kind = "index",
					index = 5,
				})
			end,
			{ nowait = true },
		},
		{
			"6",
			function()
				virt_jump.jump_with_virt_text({
					kind = "index",
					index = 6,
				})
			end,
			{ nowait = true },
		},
		{
			"7",
			function()
				virt_jump.jump_with_virt_text({
					kind = "index",
					index = 7,
				})
			end,
			{ nowait = true },
		},
		{
			"8",
			function()
				virt_jump.jump_with_virt_text({
					kind = "index",
					index = 8,
				})
			end,
			{ nowait = true },
		},
		{
			"9",
			function()
				virt_jump.jump_with_virt_text({
					kind = "index",
					index = 9,
				})
			end,
			{ nowait = true },
		},
		{
			"0",
			function()
				virt_jump.jump_with_virt_text({
					kind = "index",
					index = 10,
				})
			end,
			{ nowait = true },
		},

		{
			"F",
			function()
				virt_jump.jump_with_virt_text({
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
				virt_jump.jump_with_virt_text({
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
				virt_jump.jump_with_virt_text({
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
				virt_jump.jump_with_virt_text({
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
				virt_jump.jump_with_virt_text({
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
				virt_jump.jump_with_virt_text({
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
				virt_jump.jump_with_virt_text({
					kind = "node",
					type = { "else_statement" },
					jump_loop = true,
				})
			end,
		},
		{
			"e",
			function()
				virt_jump.jump_with_virt_text({
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
				virt_jump.jump_with_virt_text({
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
				virt_jump.jump_with_virt_text({
					kind = "field",
					type = { "condition" },
					next = true,
					jump_loop = true,
				})

				vim.fn.jobstart("cvlc ~/Sound/sc2_vo_trick_L.wav --gain=0.15 --play-and-exit")
			end,
		},

		{
			"A",
			function()
				virt_jump.jump_with_virt_text({
					kind = "field",
					type = "condition",
					descendants = {
						{ kind = "field", type = "left" },
						{ kind = "field", type = "right" },
					},
					jump_loop = true,
				})
			end,
		},
		{
			"a",
			function()
				virt_jump.jump_with_virt_text({
					kind = "field",
					type = "condition",
					descendants = {
						{ kind = "field", type = "left" },
						{ kind = "field", type = "right" },
					},
					next = true,
					jump_loop = true,
				})
			end,
		},

		{
			"<C-a>",
			function()
				vim.cmd("norm! O")

				local key = vim.api.nvim_replace_termcodes("O", true, true, true)
				vim.api.nvim_feedkeys(key, "n", false)

				vim.schedule(function()
					expand(snippets["if_statement"])

					-- vim.schedule(function()
					-- 	key = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
					-- 	vim.api.nvim_feedkeys(key, "i", false)
					-- 	vim.api.nvim_feedkeys(key, "s", false)
					-- end)
				end)
			end,
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
