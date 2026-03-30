return {
  {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function()
      -- Disable default Tab mapping (we define our own below)
      vim.g.copilot_no_tab_map = true


      -- Keybindings matching your previous setup
      vim.keymap.set("i", "<Tab>", function()
        local suggestion = vim.fn["copilot#GetDisplayedSuggestion"]()
        if suggestion.text ~= "" then
          return vim.fn["copilot#Accept"]("")
        else
          return vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
        end
      end, { expr = true, replace_keycodes = false, silent = true, desc = "Accept Copilot or indent" })
      vim.keymap.set("i", "<M-l>", "<Plug>(copilot-accept-line)", { desc = "Accept Copilot line" })
      vim.keymap.set("i", "<M-w>", "<Plug>(copilot-accept-word)", { desc = "Accept Copilot word" })
      vim.keymap.set("i", "<M-]>", "<Plug>(copilot-next)", { desc = "Next Copilot suggestion" })
      vim.keymap.set("i", "<M-[>", "<Plug>(copilot-previous)", { desc = "Previous Copilot suggestion" })
      vim.keymap.set("i", "<C-]>", "<Plug>(copilot-dismiss)", { desc = "Dismiss Copilot" })

      -- Toggle Copilot
      vim.keymap.set("n", "<leader>ct", function()
        vim.g.copilot_off = not vim.g.copilot_off
        if vim.g.copilot_off then
          vim.cmd("Copilot disable")
          vim.notify("Copilot disabled", vim.log.levels.INFO)
        else
          vim.cmd("Copilot enable")
          vim.notify("Copilot enabled", vim.log.levels.INFO)
        end
      end, { desc = "Toggle Copilot" })
    end,
  },

  -- Disable the old copilot.lua if LazyVim tries to load it
  { "zbirenbaum/copilot.lua", enabled = false },
}
