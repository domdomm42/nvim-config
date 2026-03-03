return {
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup({
        diff_binaries = false,
        enhanced_diff_hl = true,
        view = {
          merge_tool = {
            disable_diagnostics = true,
          },
        },
      })
    end,
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>",          desc = "Diffview Open" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview File History" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>",         desc = "Diffview Close" },
    },
  },
}
