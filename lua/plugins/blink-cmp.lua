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
      ["<Tab>"] = { "fallback" },
      ["<Down>"] = { "select_next" },
      ["<Up>"] = { "select_prev" },
    },
  },
}
