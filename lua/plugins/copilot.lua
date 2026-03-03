return {
  "zbirenbaum/copilot.lua",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 50,
      keymap = {
        accept_line = "<Tab>",
        accept = "<M-l>",
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
      "<leader>ct",
      function()
        local suggestion = require("copilot.suggestion")
        if suggestion.is_visible() then
          suggestion.dismiss()
        end
        vim.b.copilot_suggestion_auto_trigger = not vim.b.copilot_suggestion_auto_trigger
        vim.notify(
          "Copilot " .. (vim.b.copilot_suggestion_auto_trigger and "enabled" or "disabled"),
          vim.log.levels.INFO
        )
      end,
      desc = "Toggle Copilot",
    },
  },
}
