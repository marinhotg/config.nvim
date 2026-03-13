return {
	{
		"kdheepak/lazygit.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<leader>gg",
				function()
					local cwd_before = vim.fn.getcwd()

					local buf = vim.api.nvim_create_buf(false, true)
					vim.cmd("tabnew")
					vim.api.nvim_win_set_buf(0, buf)
					vim.bo[buf].filetype = "lazygit"

					vim.fn.termopen("lazygit", {
						on_exit = function()
							vim.schedule(function()
								pcall(vim.cmd, "tabclose")

								-- Read lazygit state file to get the last used repo
								local state_file = vim.fn.expand("~/.local/state/lazygit/state.yml")
								local file = io.open(state_file, "r")
								if file then
									local content = file:read("*a")
									file:close()

									-- Extract first repo from recentrepos list
									local new_cwd = content:match("recentrepos:%s*%-%s*([^\n]+)")
									if new_cwd and new_cwd ~= cwd_before then
										vim.cmd("cd " .. vim.fn.fnameescape(new_cwd))
										vim.cmd("e .")
										vim.notify("Switched to: " .. new_cwd, vim.log.levels.INFO)
									end
								end
							end)
						end,
					})
					vim.cmd("startinsert")
				end,
				desc = "Open Lazy[G]it",
			},
		},
	},
	{
		"crnvl96/lazydocker.nvim",
		dependencies = { "akinsho/toggleterm.nvim" },
		keys = {
			{
				"<leader>gd",
				function()
					require("lazydocker").open()
				end,
				desc = "Open Lazy[D]ocker",
			},
		},
		opts = {},
	},
}
