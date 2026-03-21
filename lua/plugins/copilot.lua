return {
  "zbirenbaum/copilot.lua",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 20,
      keymap = {
        accept = false,
        accept_line = "<M-l>",
        accept_word = "<M-w>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
    },
    panel = {
      enabled = true,
      auto_refresh = false,
    },
  },
  keys = {
    {
      "<Tab>",
      function()
        local suggestion = require("copilot.suggestion")
        if suggestion.is_visible() then
          suggestion.accept()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
        end
      end,
      mode = "i",
      desc = "Accept Copilot or indent",
    },
    {
      "<leader>ct",
      function()
        local suggestion = require("copilot.suggestion")
        if suggestion.is_visible() then
          suggestion.dismiss()
        end
        local cmd = require("copilot.command")
        vim.g.copilot_off = not vim.g.copilot_off
        if vim.g.copilot_off then
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
              vim.api.nvim_buf_call(buf, function() cmd.detach() end)
            end
          end
          vim.notify("Copilot disabled", vim.log.levels.INFO)
        else
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
              vim.api.nvim_buf_call(buf, function() cmd.attach({ force = true }) end)
            end
          end
          vim.notify("Copilot enabled", vim.log.levels.INFO)
        end
      end,
      desc = "Toggle Copilot",
    },
  },
}
