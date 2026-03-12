return {
  -- Jupyter notebook cell execution with inline output
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    init = function()
      -- Point to the dedicated jupyter venv
      vim.g.python3_host_prog = vim.fn.expand("~/.local/share/nvim/jupyter-venv/bin/python")

      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_virt_text_output = true
    end,
    keys = {
      { "<leader>mi", ":MoltenInit<CR>", desc = "Molten init kernel" },
      { "<leader>me", ":MoltenEvaluateOperator<CR>", desc = "Molten evaluate operator" },
      { "<leader>ml", ":MoltenEvaluateLine<CR>", desc = "Molten evaluate line" },
      { "<leader>mr", ":MoltenReevaluateCell<CR>", desc = "Molten re-evaluate cell" },
      { "<leader>md", ":MoltenDelete<CR>", desc = "Molten delete cell" },
      { "<leader>mo", ":MoltenShowOutput<CR>", desc = "Molten show output" },
      { "<leader>mh", ":MoltenHideOutput<CR>", desc = "Molten hide output" },
      { "<leader>me", ":<C-u>MoltenEvaluateVisual<CR>gv", mode = "v", desc = "Molten evaluate visual" },
    },
  },

  -- Inline image rendering (Ghostty supports kitty graphics protocol)
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      max_height_window_percentage = 50,
      integrations = {
        markdown = { enabled = false },
      },
    },
  },

  -- Auto-convert .ipynb to editable Python with # %% cell markers
  {
    "GCBallesteros/jupytext.nvim",
    opts = {
      style = "percent",
      output_extension = "auto",
      force_ft = nil,
    },
  },
}
