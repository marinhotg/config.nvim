return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = 20,
				shade_terminals = true,
				direction = "float",
				float_opts = {
					border = "curved",
					width = function()
						return math.floor(vim.o.columns * 0.85)
					end,
					height = function()
						return math.floor(vim.o.lines * 0.8)
					end,
				},
				start_in_insert = true,
				insert_mappings = true,
				terminal_mappings = true,
			})

			local Terminal = require("toggleterm.terminal").Terminal

			local term1 = Terminal:new({ count = 1, direction = "float" })
			local term2 = Terminal:new({ count = 2, direction = "float" })

			local map = vim.keymap.set
			map({ "n", "t" }, "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Toggle [T]erminal" })
			map({ "n", "t" }, "<leader>t1", function()
				term1:toggle()
			end, { desc = "Toggle Terminal 1" })
			map({ "n", "t" }, "<leader>t2", function()
				term2:toggle()
			end, { desc = "Toggle Terminal 2" })
		end,
	},
}
