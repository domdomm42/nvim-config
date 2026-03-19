return {
  "coder/claudecode.nvim",
  opts = {
    focus_after_send = true,
    diff_opts = {
      layout = "vertical",
      open_in_new_tab = true,
    },
  },
  config = function(_, opts)
    require("claudecode").setup(opts)

    -- Auto-copy on mouse select in terminal buffers (like tmux copy-on-select)
    vim.api.nvim_create_autocmd("TermOpen", {
      callback = function()
        vim.keymap.set("v", "<LeftRelease>", '"+y', { buffer = true, silent = true })
      end,
    })
  end,
  keys = {
    {
      "<leader>as",
      "<cmd>ClaudeCodeSend<cr>",
      mode = "v",
      desc = "Send to Claude",
    },
  },
}
