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

      -- Make output text normal white instead of greyed out
      vim.api.nvim_set_hl(0, "MoltenVirtualText", { fg = "#ffffff" })

      -- Subtle background highlight for the active cell
      vim.api.nvim_set_hl(0, "MoltenCell", { bg = "#1a1a2e" })

      -- Draw horizontal separator lines above # %% cell markers
      local function draw_cell_separators(buf)
        local ns = vim.api.nvim_create_namespace("jupyter_cell_separator")
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        for i, line in ipairs(lines) do
          if line:match("^# %%%%") then
            vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
              virt_lines_above = true,
              virt_lines = { { { string.rep("─", 80), "Comment" } } },
            })
          end
        end
      end

      vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost", "TextChanged", "TextChangedI", "FileType" }, {
        pattern = "*",
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          local ft = vim.bo[buf].filetype
          if ft == "python" then
            vim.defer_fn(function()
              if vim.api.nvim_buf_is_valid(buf) then
                draw_cell_separators(buf)
              end
            end, 100)
          end
        end,
      })
    end,
    keys = {
      { "<leader>mi", ":MoltenInit<CR>", desc = "Molten init kernel" },
      { "<leader>me", ":MoltenEvaluateOperator<CR>", desc = "Molten evaluate operator" },
      { "<leader>ml", ":MoltenEvaluateLine<CR>", desc = "Molten evaluate line" },
      { "<leader>mr", ":MoltenReevaluateCell<CR>", desc = "Molten re-evaluate cell" },
      { "<leader>md", ":MoltenDelete<CR>", desc = "Molten delete cell" },
      { "<leader>mo", ":MoltenShowOutput<CR>", desc = "Molten show output" },
      { "<leader>mh", ":MoltenHideOutput<CR>", desc = "Molten hide output" },
      { "<leader>ms", ":noautocmd MoltenEnterOutput<CR>", desc = "Molten enter/scroll output" },
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
