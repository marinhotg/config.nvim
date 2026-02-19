return {
	"nvim-telescope/telescope.nvim",
	keys = {
		{
			"<leader>sp",
			function()
				local pickers = require("telescope.pickers")
				local finders = require("telescope.finders")
				local conf = require("telescope.config").values
				local actions = require("telescope.actions")
				local action_state = require("telescope.actions.state")

				local articles_dir = vim.fn.expand("~/articles")
				local find_cmd = { "find", articles_dir, "-type", "f", "-name", "*.pdf" }

				pickers
					.new({}, {
						prompt_title = "Articles (PDF)",
						finder = finders.new_oneshot_job(find_cmd, {
							entry_maker = function(line)
								local name = vim.fn.fnamemodify(line, ":t:r")
								return {
									value = line,
									display = name,
									ordinal = name,
								}
							end,
						}),
						sorter = conf.generic_sorter({}),
						attach_mappings = function(prompt_bufnr)
							actions.select_default:replace(function()
								actions.close(prompt_bufnr)
								local entry = action_state.get_selected_entry()
								if entry then
									vim.fn.jobstart({ "zathura", entry.value }, { detach = true })
								end
							end)
							return true
						end,
					})
					:find()
			end,
			desc = "[S]earch [P]DFs (Articles)",
		},
	},
}
