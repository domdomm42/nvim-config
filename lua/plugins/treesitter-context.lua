return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      enable = true,
      multiwindow = false,
      max_lines = 0,
      min_window_height = 0,
      line_numbers = true,
      multiline_threshold = 20,
      trim_scope = "outer",
      mode = "cursor",
      separator = nil,
      zindex = 20,
    },
    config = function(_, opts)
      require("treesitter-context").setup(opts)
      vim.api.nvim_set_hl(0, "TreesitterContext", { link = "CursorLine" })
      vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { link = "CursorLine" })
    end,
  },
}
