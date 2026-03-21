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

      -- Per-cell and global virtual text hiding
      -- Strategy: when hiding, store the virt_lines content and replace with empty.
      -- When showing, restore from stored content. Molten won't touch the extmark
      -- because its internal state thinks it's already rendered (DONE + valid ID).
      local molten_hidden_cells = {} -- ["bufnr:marker_line"] = true
      local molten_all_hidden = false
      local stored_virt_lines = {} -- [extmark_id] = { virt_lines data }

      local function get_cell_marker_line()
        local cursor = vim.fn.line(".")
        local lines = vim.api.nvim_buf_get_lines(0, 0, cursor, false)
        for i = #lines, 1, -1 do
          if lines[i]:match("^# %%%%") then
            return i -- 1-indexed
          end
        end
        return nil
      end

      local function get_cell_end_line(marker_line)
        local total = vim.api.nvim_buf_line_count(0)
        local lines = vim.api.nvim_buf_get_lines(0, marker_line, total, false)
        for i, line in ipairs(lines) do
          if line:match("^# %%%%") then
            return marker_line + i - 1
          end
        end
        return total
      end

      local function hide_virt_text_in_range(buf, start_0, end_0)
        local ns = vim.api.nvim_create_namespace("molten-extmarks")
        local marks = vim.api.nvim_buf_get_extmarks(buf, ns, { start_0, 0 }, { end_0, -1 }, { details = true })
        for _, mark in ipairs(marks) do
          if mark[4] and mark[4].virt_lines and #mark[4].virt_lines > 0 then
            stored_virt_lines[mark[1]] = mark[4].virt_lines
            vim.api.nvim_buf_set_extmark(buf, ns, mark[2], mark[3], {
              id = mark[1],
              virt_lines = {},
            })
          end
        end
      end

      local function show_virt_text_in_range(buf, start_0, end_0)
        local ns = vim.api.nvim_create_namespace("molten-extmarks")
        local marks = vim.api.nvim_buf_get_extmarks(buf, ns, { start_0, 0 }, { end_0, -1 }, { details = true })
        for _, mark in ipairs(marks) do
          local saved = stored_virt_lines[mark[1]]
          if saved then
            vim.api.nvim_buf_set_extmark(buf, ns, mark[2], mark[3], {
              id = mark[1],
              virt_lines = saved,
            })
            stored_virt_lines[mark[1]] = nil
          end
        end
      end

      local function show_all_virt_text(buf)
        show_virt_text_in_range(buf, 0, -1)
      end

      -- Re-hide after Molten re-renders on cursor move
      vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          if vim.bo[buf].filetype ~= "python" then
            return
          end
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(buf) then
              return
            end
            if molten_all_hidden then
              hide_virt_text_in_range(buf, 0, -1)
              return
            end
            for key, _ in pairs(molten_hidden_cells) do
              local b, m = key:match("^(%d+):(%d+)$")
              b, m = tonumber(b), tonumber(m)
              if b == buf then
                local end_line = get_cell_end_line(m)
                hide_virt_text_in_range(buf, m - 1, end_line)
              end
            end
          end)
        end,
      })

      -- Expose toggle functions for keymaps
      _G.molten_toggle_cell_output = function()
        local marker = get_cell_marker_line()
        if not marker then
          vim.notify("Not in a cell")
          return
        end
        local buf = vim.api.nvim_get_current_buf()
        local key = buf .. ":" .. marker
        if molten_hidden_cells[key] then
          molten_hidden_cells[key] = nil
          local end_line = get_cell_end_line(marker)
          show_virt_text_in_range(buf, marker - 1, end_line)
          vim.notify("Cell output: shown")
        else
          molten_hidden_cells[key] = true
          local end_line = get_cell_end_line(marker)
          hide_virt_text_in_range(buf, marker - 1, end_line)
          vim.notify("Cell output: hidden")
        end
      end

      _G.molten_toggle_all_output = function()
        molten_all_hidden = not molten_all_hidden
        local buf = vim.api.nvim_get_current_buf()
        if molten_all_hidden then
          hide_virt_text_in_range(buf, 0, -1)
        else
          molten_hidden_cells = {}
          show_all_virt_text(buf)
        end
        vim.notify("All output: " .. (molten_all_hidden and "hidden" or "shown"))
      end

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
      { "<leader>md", ":MoltenDelete<CR>", desc = "Molten delete cell output" },
      { "<leader>mo", ":MoltenShowOutput<CR>", desc = "Molten show output" },
      { "<leader>mh", ":MoltenHideOutput<CR>", desc = "Molten hide output" },
      { "<leader>ms", ":noautocmd MoltenEnterOutput<CR>", desc = "Molten enter/scroll output" },
      { "<leader>me", ":<C-u>MoltenEvaluateVisual<CR><Esc>", mode = "v", desc = "Molten evaluate visual" },
      { "<leader>mt", function() _G.molten_toggle_all_output() end, desc = "Toggle all output visibility" },
      { "<leader>mc", function() _G.molten_toggle_cell_output() end, desc = "Toggle current cell output" },
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
