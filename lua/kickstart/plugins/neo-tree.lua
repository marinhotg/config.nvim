-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

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
    { '<leader>e', ':Neotree toggle<CR>', desc = 'Toggle file explorer', silent = true },
    { '<leader>o', ':Neotree reveal<CR>', desc = 'Open file explorer on left', silent = true },
    { '<leader>p', ':Neotree reveal position=right<CR>', desc = 'Open file explorer on right', silent = true },
  },
  config = function()
    require('neo-tree').setup {
      sources = { 'filesystem', 'buffers', 'git_status' },
      filesystem = {
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = 'open_default',
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false,
        },
      },

      event_handlers = {
        {
          event = 'vim_buffer_enter',
          handler = function()
            if package.loaded['neo-tree.sources.manager'] then
              require('neo-tree.sources.manager').refresh 'filesystem'
            end
          end,
        },
        {
          event = 'neo_tree_buffer_enter',
          handler = function()
            if package.loaded['neo-tree.sources.manager'] then
              require('neo-tree.sources.manager').refresh 'filesystem'
            end
          end,
        },
      },

      window = {
        position = 'left', -- default position
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

    vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
      callback = function()
        if package.loaded['neo-tree.sources.manager'] then
          require('neo-tree.sources.manager').refresh 'filesystem'
        end
      end,
    })

    vim.keymap.set('n', '<leader>nr', function()
      if package.loaded['neo-tree.sources.manager'] then
        require('neo-tree.sources.manager').refresh 'filesystem'
        vim.notify('Neo-tree refreshed!', vim.log.levels.INFO)
      end
    end, { desc = '[N]eotree [R]efresh' })
  end,
}
