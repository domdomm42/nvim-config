-- Send file context to AI tmux panes created by tdl
-- Finds panes by case-insensitive substring match on pane title
local pane_patterns = {
  opencode = { "opencode", "OC " },
  claude = { "claude" },
}

local function find_pane(name)
  local handle = io.popen("tmux list-panes -F '#{pane_id} #{pane_title}' 2>/dev/null")
  if not handle then
    return nil
  end
  local output = handle:read("*a")
  handle:close()

  local patterns = pane_patterns[name] or { name }
  for line in output:gmatch("[^\n]+") do
    local id, title = line:match("^(%S+)%s+(.+)$")
    if title then
      for _, pattern in ipairs(patterns) do
        if title:lower():find(pattern:lower(), 1, true) then
          return id
        end
      end
    end
  end
  return nil
end

local function escape_for_tmux(text)
  text = text:gsub("\\", "\\\\")
  text = text:gsub(";", "\\;")
  text = text:gsub("%$", "\\$")
  text = text:gsub("`", "\\`")
  return text
end

local function get_visual_selection()
  vim.cmd('noautocmd normal! gv"vy')
  return vim.fn.getreg("v")
end

local function send_to_pane(pattern, mode)
  local pane_id = find_pane(pattern)
  if not pane_id then
    vim.notify("tmux pane matching '" .. pattern .. "' not found", vim.log.levels.WARN)
    return
  end

  local file = vim.fn.expand("%:.")
  if file == "" then
    vim.notify("No file open", vim.log.levels.WARN)
    return
  end

  local text
  if mode == "v" then
    local start_line = vim.fn.getpos("v")[2]
    local end_line = vim.fn.getpos(".")[2]
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    text = string.format("@%s:%d-%d ", file, start_line, end_line)
  elseif mode == "f" then
    text = string.format("@%s ", file)
  else
    local line = vim.fn.line(".")
    text = string.format("@%s:%d ", file, line)
  end

  local escaped = escape_for_tmux(text)
  vim.fn.system(string.format("tmux send-keys -t %s -l %s", pane_id, vim.fn.shellescape(escaped)))
  vim.fn.system(string.format("tmux select-pane -t %s", pane_id))
end

return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>i", group = "input to AI" },
      },
    },
  },
  {
    dir = "~",
    name = "tmux-chat",
    keys = {
      { "<leader>io", function() send_to_pane("opencode", "f") end, mode = "n", desc = "Send file path to opencode" },
      { "<leader>ic", function() send_to_pane("claude", "f") end, mode = "n", desc = "Send file path to claude" },
      { "<leader>io", function() send_to_pane("opencode", "v") end, mode = "v", desc = "Send selection to opencode" },
      { "<leader>ic", function() send_to_pane("claude", "v") end, mode = "v", desc = "Send selection to claude" },
    },
  },
}
