return {
	{
		"kdheepak/lazygit.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<leader>gg",
				function()
					vim.cmd("tabnew")
					vim.cmd("terminal lazygit")
					vim.cmd("startinsert")

					vim.api.nvim_create_autocmd("TermClose", {
						buffer = vim.api.nvim_get_current_buf(),
						callback = function()
							vim.schedule(function()
								vim.cmd("tabclose")
							end)
						end,
						once = true,
					})
				end,
				desc = "Open Lazy[G]it",
			},
		},
	},
}
