return {
	"ThePrimeagen/git-worktree.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("git-worktree").setup({
			change_directory_command = "cd",
			update_on_change = true,
			update_on_change_command = "e .",
			autopush = false,
		})

		require("telescope").load_extension("git_worktree")

		local Worktree = require("git-worktree")

		Worktree.on_tree_change(function(op, metadata)
			if op == Worktree.Operations.Switch then
				vim.notify("Switched to worktree: " .. metadata.path, vim.log.levels.INFO)
			end
			if op == Worktree.Operations.Create then
				vim.notify("Created worktree: " .. metadata.path, vim.log.levels.INFO)
			end
			if op == Worktree.Operations.Delete then
				vim.notify("Deleted worktree: " .. metadata.prev_path, vim.log.levels.INFO)
			end
		end)
	end,
	keys = {
		{
			"<leader>gw",
			function()
				require("telescope").extensions.git_worktree.git_worktrees()
			end,
			desc = "List [G]it [W]orktrees",
		},
	},
}
