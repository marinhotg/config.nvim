return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      local function is_neo_tree_open()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype
          if ft == "neo-tree" then
            return true
          end
        end
        return false
      end

      local function close_neo_tree_if_open()
        if is_neo_tree_open() then
          pcall(vim.cmd, "Neotree close")
        end
      end

      require("toggleterm").setup({
        size = 15,
        shade_terminals = true,
        direction = "float",
        float_opts = { border = "curved" },
        -- Se quiser abrir sempre em insert no terminal
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        on_open = function(term)
          if term and term.direction == "vertical" then
            close_neo_tree_if_open()
          end
        end,
      })

      local Terminal = require("toggleterm.terminal").Terminal

      -- Terminal dedicado para LazyGit (float)
      local lazygit_term = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
      })

      -- Dois terminais dedicados
      local term1 = Terminal:new({ count = 1, direction = "vertical" })
      local term2 = Terminal:new({ count = 2, direction = "float" })

      -- Atalhos
      local map = vim.keymap.set
      map("n", "<leader>tt", "<cmd>ToggleTerm direction=float<CR>", { desc = "Toggle [T]erminal (float)" })
      map("n", "<leader>tv", function()
        term1:toggle(60)
      end, { desc = "Toggle Terminal [V]ertical (T1)" })
      map({ "n", "t" }, "<leader>t1", function()
        term1:toggle(60)
      end, { desc = "Toggle Terminal 1 (vertical)" })
      map({ "n", "t" }, "<leader>t2", function()
        term2:toggle()
      end, { desc = "Toggle Terminal 2 (float)" })
      map({ "n", "t" }, "<leader>tg", function()
        lazygit_term:toggle()
      end, { desc = "Toggle Lazy[G]it (float)" })

      -- Dica: você já tem <Esc><Esc> para sair do modo terminal (definido no seu init.lua)
    end,
  },
}
