return {
  "coder/claudecode.nvim",
  opts = {
    terminal = {
      provider = "external",
      provider_opts = {
        external_terminal_cmd = function(cmd_string, env_table)
          local pane_id = vim.env.TDL_CLAUDE_PANE

          if pane_id then
            -- tdl already created a pane for claude — send the command there with env vars
            local env_parts = {}
            for k, v in pairs(env_table) do
              table.insert(env_parts, k .. "=" .. tostring(v))
            end
            local full_cmd = "export " .. table.concat(env_parts, " ") .. "; " .. cmd_string
            -- Use -l (literal) to avoid escape sequence interpretation, then send Enter separately
            vim.fn.system({ "tmux", "send-keys", "-t", pane_id, "-l", full_cmd })
            vim.fn.system({ "tmux", "send-keys", "-t", pane_id, "Enter" })
            return { "tail", "-f", "/dev/null" }
          else
            -- No tdl pane — create a new tmux split
            local args = { "tmux", "split-window", "-h", "-l", "40%" }
            for k, v in pairs(env_table) do
              table.insert(args, "-e")
              table.insert(args, k .. "=" .. tostring(v))
            end
            table.insert(args, cmd_string)
            return args
          end
        end,
      },
    },
    diff_opts = {
      vertical_split = true,
    },
  },
  -- Auto-start ClaudeCode when launched from tdl
  init = function()
    if vim.env.TDL_CLAUDE_PANE then
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = function()
          require("lazy").load({ plugins = { "claudecode.nvim" } })
          vim.schedule(function()
            vim.cmd("ClaudeCode")
          end)
        end,
      })
    end
  end,
}
