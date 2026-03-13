return {
	dir = vim.fn.stdpath("config"),
	name = "claude-agents",
	event = "VeryLazy",
	config = function()
		local agents = {} -- {[slot]={bufnr=int, job_id=int, path=string, branch=string}}
		local agents_tabnr = nil
		local MAX_AGENTS = 3

		-- Helpers

		local function get_git_toplevel()
			return vim.fn.system("git rev-parse --show-toplevel"):gsub("%s+$", "")
		end

		local function get_wt_base()
			local toplevel = get_git_toplevel()
			local repo = vim.fn.fnamemodify(toplevel, ":t")
			return vim.fn.fnamemodify(toplevel, ":h") .. "/" .. repo .. "-wt"
		end

		local function list_worktrees()
			local out = vim.fn.system("git worktree list --porcelain")
			local worktrees = {}
			local current = {}
			for line in out:gmatch("[^\n]+") do
				if line:match("^worktree ") then
					current = { path = line:match("^worktree (.+)") }
				elseif line:match("^branch ") then
					current.branch = line:match("^branch refs/heads/(.+)")
					table.insert(worktrees, current)
				elseif line:match("^detached") then
					current.branch = "(detached)"
					table.insert(worktrees, current)
				end
			end
			return worktrees
		end

		local function next_free_slot()
			for i = 1, MAX_AGENTS do
				if not agents[i] then
					return i
				end
			end
			return nil
		end

		--- Spawn a terminal buffer for an agent. Does NOT create any window.
		local function create_agent_buf(slot, worktree_path, branch)
			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")

			-- We need a window to run termopen, use a temp hidden split
			local prev_win = vim.api.nvim_get_current_win()
			vim.cmd("botright 1split")
			local tmp_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(tmp_win, buf)

			local job_id = vim.fn.termopen("bash", {
				cwd = worktree_path,
				on_exit = function() end,
			})

			-- Close temp window, restore previous
			vim.api.nvim_win_close(tmp_win, true)
			pcall(vim.api.nvim_set_current_win, prev_win)

			-- Send claude command after shell initializes
			vim.defer_fn(function()
				if vim.api.nvim_buf_is_valid(buf) then
					pcall(vim.api.nvim_chan_send, job_id, "claude\n")
				end
			end, 300)

			agents[slot] = {
				bufnr = buf,
				job_id = job_id,
				path = worktree_path,
				branch = branch or "",
			}
		end

		-- Agents tab management

		local function is_agents_tab_valid()
			if agents_tabnr == nil then
				return false
			end
			return pcall(vim.api.nvim_tabpage_get_number, agents_tabnr)
		end

		local function open_agents_tab()
			local active_slots = {}
			for slot = 1, MAX_AGENTS do
				if agents[slot] then
					table.insert(active_slots, slot)
				end
			end
			if #active_slots == 0 then
				vim.notify("No agents running. Use <leader>an or <leader>ap first.", vim.log.levels.WARN)
				return
			end

			if is_agents_tab_valid() then
				vim.api.nvim_set_current_tabpage(agents_tabnr)
				return
			end

			-- Create new tab, first agent takes the window
			vim.cmd("tabnew")
			agents_tabnr = vim.api.nvim_get_current_tabpage()
			vim.api.nvim_win_set_buf(0, agents[active_slots[1]].bufnr)

			-- Additional agents get vsplits
			for i = 2, #active_slots do
				vim.cmd("vsplit")
				vim.api.nvim_win_set_buf(0, agents[active_slots[i]].bufnr)
			end

			vim.cmd("wincmd =")
			vim.cmd("startinsert")
		end

		local function toggle_agents_tab()
			if is_agents_tab_valid() then
				if vim.api.nvim_get_current_tabpage() == agents_tabnr then
					vim.cmd("tabprevious")
				else
					vim.api.nvim_set_current_tabpage(agents_tabnr)
				end
			else
				open_agents_tab()
			end
		end

		local function focus_agent(slot)
			if not agents[slot] then
				vim.notify("No agent in slot " .. slot, vim.log.levels.WARN)
				return
			end

			if not is_agents_tab_valid() then
				open_agents_tab()
				return
			end

			vim.api.nvim_set_current_tabpage(agents_tabnr)

			for _, win in ipairs(vim.api.nvim_tabpage_list_wins(agents_tabnr)) do
				if vim.api.nvim_win_get_buf(win) == agents[slot].bufnr then
					vim.api.nvim_set_current_win(win)
					vim.cmd("startinsert")
					return
				end
			end
		end

		local function kill_agent_in_current_window()
			local current_buf = vim.api.nvim_get_current_buf()
			for slot = 1, MAX_AGENTS do
				if agents[slot] and agents[slot].bufnr == current_buf then
					pcall(vim.fn.jobstop, agents[slot].job_id)
					pcall(vim.api.nvim_buf_delete, agents[slot].bufnr, { force = true })
					agents[slot] = nil
					vim.notify("Agent " .. slot .. " killed", vim.log.levels.INFO)

					local wins = vim.api.nvim_tabpage_list_wins(0)
					if #wins > 1 then
						vim.cmd("wincmd =")
					else
						vim.cmd("tabclose")
						agents_tabnr = nil
					end
					return
				end
			end
			vim.notify("No agent in current window", vim.log.levels.WARN)
		end

		-- Spawn flows

		local function spawn_agent_for_worktree(worktree_path, branch)
			local slot = next_free_slot()
			if not slot then
				vim.notify("All " .. MAX_AGENTS .. " agent slots occupied", vim.log.levels.ERROR)
				return
			end

			create_agent_buf(slot, worktree_path, branch)
			vim.notify("Agent " .. slot .. " spawned on " .. (branch or worktree_path), vim.log.levels.INFO)

			if is_agents_tab_valid() then
				vim.api.nvim_set_current_tabpage(agents_tabnr)
				vim.cmd("vsplit")
				vim.api.nvim_win_set_buf(0, agents[slot].bufnr)
				vim.cmd("wincmd =")
				vim.cmd("startinsert")
			else
				open_agents_tab()
			end
		end

		local function new_agent()
			vim.ui.input({ prompt = "Branch name: " }, function(branch_name)
				if not branch_name or branch_name == "" then
					return
				end

				local result = vim.fn.system({ "git-wt-add", "", branch_name })
				if vim.v.shell_error ~= 0 then
					vim.notify("Failed to create worktree: " .. result, vim.log.levels.ERROR)
					return
				end

				local dir_name = branch_name:gsub("/", "-")
				local worktree_path = get_wt_base() .. "/" .. dir_name
				spawn_agent_for_worktree(worktree_path, branch_name)
			end)
		end

		local function pick_worktree()
			local worktrees = list_worktrees()
			local toplevel = get_git_toplevel()
			local available = {}
			local assigned_paths = {}
			for _, a in pairs(agents) do
				assigned_paths[a.path] = true
			end

			for _, wt in ipairs(worktrees) do
				if wt.path ~= toplevel and not assigned_paths[wt.path] then
					table.insert(available, wt)
				end
			end

			if #available == 0 then
				vim.notify("No available worktrees. Create one with <leader>an", vim.log.levels.WARN)
				return
			end

			local items = {}
			for _, wt in ipairs(available) do
				table.insert(items, wt.branch .. " (" .. wt.path .. ")")
			end

			vim.ui.select(items, { prompt = "Select worktree for agent:" }, function(_, idx)
				if not idx then
					return
				end
				local wt = available[idx]
				spawn_agent_for_worktree(wt.path, wt.branch)
			end)
		end

		-- Keybindings
		local map = vim.keymap.set
		map("n", "<leader>aa", toggle_agents_tab, { desc = "Toggle [A]gents tab" })
		map("n", "<leader>an", new_agent, { desc = "[A]gent [N]ew (create worktree + spawn)" })
		map("n", "<leader>ap", pick_worktree, { desc = "[A]gent [P]ick worktree" })
		map({ "n", "t" }, "<leader>a1", function()
			focus_agent(1)
		end, { desc = "[A]gent 1 focus" })
		map({ "n", "t" }, "<leader>a2", function()
			focus_agent(2)
		end, { desc = "[A]gent 2 focus" })
		map({ "n", "t" }, "<leader>a3", function()
			focus_agent(3)
		end, { desc = "[A]gent 3 focus" })
		map({ "n", "t" }, "<leader>ax", kill_agent_in_current_window, { desc = "[A]gent kill current" })
	end,
}
