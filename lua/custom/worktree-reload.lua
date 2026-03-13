local M = {}

local skip_filetypes = {
	"neo-tree",
	"toggleterm",
	"TelescopePrompt",
	"qf",
	"help",
	"fugitive",
	"NvimTree",
}

local function is_code_buffer(bufnr)
	if vim.bo[bufnr].buftype ~= "" then
		return false
	end
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return false
	end
	local ft = vim.bo[bufnr].filetype
	for _, skip in ipairs(skip_filetypes) do
		if ft == skip then
			return false
		end
	end
	return true
end

function M.reload_buffers(prev_root, new_root)
	-- Normalize: ensure trailing slash for prefix matching
	local prev_prefix = vim.fn.fnamemodify(prev_root, ":p")
	local new_prefix = vim.fn.fnamemodify(new_root, ":p")

	local old_bufs_to_delete = {}

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local bufnr = vim.api.nvim_win_get_buf(win)
		if is_code_buffer(bufnr) then
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			if vim.startswith(bufname, prev_prefix) then
				local rel = bufname:sub(#prev_prefix + 1)
				local new_path = new_prefix .. rel

				if vim.fn.filereadable(new_path) == 1 then
					-- Save cursor before switching
					local cursor = vim.api.nvim_win_get_cursor(win)

					local new_buf = vim.fn.bufadd(new_path)
					vim.fn.bufload(new_buf)
					vim.api.nvim_win_set_buf(win, new_buf)

					-- Restore cursor with clamping
					local line_count = vim.api.nvim_buf_line_count(new_buf)
					local row = math.min(cursor[1], line_count)
					local line = vim.api.nvim_buf_get_lines(new_buf, row - 1, row, false)[1] or ""
					local col = math.min(cursor[2], #line)
					vim.api.nvim_win_set_cursor(win, { row, col })

					old_bufs_to_delete[bufnr] = true
				else
					vim.notify("Worktree: file not found in new tree: " .. rel, vim.log.levels.WARN)
				end
			end
		end
	end

	-- Delete old buffers that are no longer visible and not modified
	for bufnr, _ in pairs(old_bufs_to_delete) do
		if vim.api.nvim_buf_is_valid(bufnr) and not vim.bo[bufnr].modified then
			local still_visible = false
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				if vim.api.nvim_win_get_buf(win) == bufnr then
					still_visible = true
					break
				end
			end
			if not still_visible then
				vim.api.nvim_buf_delete(bufnr, { force = false })
			end
		end
	end
end

return M
