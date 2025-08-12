return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    {
      '<leader>e',
      function()
        if vim.g.__neotree_toggle_busy then return end
        vim.g.__neotree_toggle_busy = true
        vim.defer_fn(function() vim.g.__neotree_toggle_busy = false end, 200)

        local any_open = false
        local has_right = false
        local total_cols = vim.o.columns
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'neo-tree' then
            any_open = true
            local pos = vim.fn.win_screenpos(win)
            local col = type(pos) == 'table' and pos[2] or 1
            local width = vim.api.nvim_win_get_width(win)
            if col + width - 1 >= total_cols then
              has_right = true
            end
          end
        end

        local open_right_after_close = false
        if any_open then
          pcall(function() require('neo-tree.command').execute { action = 'close' } end)
          if has_right then
            vim.schedule(function()
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].filetype == 'neo-tree' then
                  pcall(vim.api.nvim_win_close, win, true)
                end
              end
            end)
          else
            open_right_after_close = true
          end
          vim.g.__neotree_last_closed_at = (vim.uv or vim.loop).now()
        else
          open_right_after_close = true
        end

        if open_right_after_close then
          local current_path = vim.api.nvim_buf_get_name(0)
          local has_file = type(current_path) == 'string' and current_path ~= '' and (vim.uv or vim.loop).fs_stat(current_path) ~= nil
          if has_file then
            require('neo-tree.command').execute {
              action = 'reveal',
              source = 'filesystem',
              position = 'right',
              reveal_file = current_path,
              reveal_force_cwd = true,
            }
          else
            require('neo-tree.command').execute { action = 'show', source = 'filesystem', position = 'right' }
          end
        end
      end,
      desc = 'Toggle file explorer',
      silent = true,
      nowait = true,
    },
    { '<leader>o', ':Neotree reveal<CR>', desc = 'Open file explorer on right', silent = true },
    { '<leader>p', ':Neotree reveal position=left<CR>', desc = 'Open file explorer on left', silent = true },
  },
  config = function()
    local function is_neo_tree_window_open()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == 'neo-tree' then
          return true
        end
      end
      return false
    end

    require('neo-tree').setup {
      close_if_last_window = true,
      sources = { 'filesystem', 'buffers', 'git_status' },
      filesystem = {
        follow_current_file = { enabled = false },
        hijack_netrw_behavior = 'disabled',
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false,
        },
      },

      event_handlers = {},

      window = {
        position = 'right',
        mappings = {
          ['<space>'] = 'none',
          ['<cr>'] = 'open',
          ['<esc>'] = 'revert_preview',
          ['P'] = { 'toggle_preview', config = { use_float = true } },
          ['S'] = 'open_split',
          ['s'] = 'open_vsplit',
          ['t'] = 'open_tabnew',
          ['a'] = 'add',
          ['A'] = 'add_directory',
          ['d'] = 'delete',
          ['r'] = 'rename',
          ['y'] = 'copy_to_clipboard',
          ['x'] = 'cut_to_clipboard',
          ['p'] = 'paste_from_clipboard',
          ['c'] = 'copy',
          ['m'] = 'move',
          ['q'] = 'close_window',
          ['R'] = 'refresh',
          ['?'] = 'show_help',
          ['<'] = 'prev_source',
          ['>'] = 'next_source',
          ['<bs>'] = 'navigate_up',
          ['.'] = 'set_root',
          ['H'] = 'toggle_hidden',
          ['/'] = 'fuzzy_finder',
          ['D'] = 'fuzzy_finder_directory',
          ['f'] = 'filter_on_submit',
          ['<c-x>'] = 'clear_filter',
        },
      },
    }

    vim.keymap.set('n', '<leader>nr', function()
      if package.loaded['neo-tree.sources.manager'] then
        require('neo-tree.sources.manager').refresh 'filesystem'
        vim.notify('Neo-tree refreshed!', vim.log.levels.INFO)
      end
    end, { desc = '[N]eotree [R]efresh' })

    local function toggle_neotree_right()
      local ok, err = pcall(function()
        local neo_open = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'neo-tree' then
            neo_open = true
            break
          end
        end

        if neo_open then
          vim.cmd('Neotree close')
          return
        end

        vim.cmd('Neotree reveal position=right')
      end)
      if not ok and err then
        vim.notify('Neo-tree toggle error: ' .. tostring(err), vim.log.levels.ERROR)
      end
    end

    pcall(vim.keymap.del, 'n', '<leader>e')
    vim.keymap.set('n', '<leader>e', toggle_neotree_right, { desc = 'Toggle file explorer (right)', silent = true, noremap = true })
  end,
}
