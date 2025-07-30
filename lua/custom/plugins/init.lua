return {
  -- Lazygit integration
  {
    'kdheepak/lazygit.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'Open Lazy[G]it' },
    },
  },

  -- Advanced diffing
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = '[G]it [D]iff' },
      { '<leader>gh', '<cmd>DiffviewFileHistory<cr>', desc = '[G]it [H]istory' },
    },
  },
}
