return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      ghost_text = {
        enabled = false, -- Disable blink's ghost text, use only Copilot
      },
    },
    keymap = {
      preset = "enter",
      ["<C-y>"] = { "select_and_accept" },
      ["<Tab>"] = {
        function(cmp)
          local copilot = require("copilot.suggestion")
          if copilot.is_visible() then
            copilot.accept()
          end
          -- Don't do anything else - let arrow keys handle menu navigation
        end,
      },
      ["<Down>"] = { "select_next" },
      ["<Up>"] = { "select_prev" },
    },
  },
}
