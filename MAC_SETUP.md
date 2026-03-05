# Mac Setup Instructions

Set up the same nvim + Claude Code + opencode tmux dev layout on macOS.

## Prerequisites

Install these first:

```bash
brew install tmux neovim
npm install -g @anthropic-ai/claude-code   # or: claude migrate-installer
# Install opencode however you have it set up
```

## 1. Clone the nvim config

```bash
git clone git@github.com:domdomm42/nvim-config.git ~/.config/nvim
```

## 2. Symlink the tmux config

```bash
mkdir -p ~/.config/tmux
ln -sf ~/.config/nvim/tmux/tmux.conf ~/.config/tmux/tmux.conf
```

## 3. Add shell aliases and the `tdl` function

Add the following to your shell rc file (`~/.bashrc`, `~/.zshrc`, or equivalent):

```bash
# AI aliases
alias c='opencode'
alias cx='printf "\033[2J\033[3J\033[H" && claude'

# Tmux Dev Layout — opens nvim + AI panes + terminal
# Usage: tdl <c|cx|other_ai> [<second_ai>]
# When "cx" (Claude Code) is used, it launches via nvim's claudecode.nvim plugin
# so you get inline diffs in nvim (accept with <leader>aa, reject with <leader>ad)
tdl() {
  [[ -z $1 ]] && { echo "Usage: tdl <c|cx|codex|other_ai> [<second_ai>]"; return 1; }
  [[ -z $TMUX ]] && { echo "You must start tmux to use tdl."; return 1; }

  local current_dir="${PWD}"
  local editor_pane ai_pane ai2_pane
  local ai="$1"
  local ai2="$2"
  local claude_pane=""

  editor_pane="$TMUX_PANE"
  tmux rename-window -t "$editor_pane" "$(basename "$current_dir")"

  # Bottom terminal pane (15%)
  tmux split-window -v -p 15 -t "$editor_pane" -c "$current_dir"

  # Right AI pane (30%)
  ai_pane=$(tmux split-window -h -p 30 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
  tmux select-pane -t "$ai_pane" -T "ai1"

  if [[ "$ai" == "cx" ]]; then
    claude_pane="$ai_pane"
  else
    tmux send-keys -t "$ai_pane" "$ai" C-m
  fi

  # Second AI pane (split ai pane vertically)
  if [[ -n $ai2 ]]; then
    ai2_pane=$(tmux split-window -v -t "$ai_pane" -c "$current_dir" -P -F '#{pane_id}')
    tmux select-pane -t "$ai2_pane" -T "ai2"

    if [[ "$ai2" == "cx" ]]; then
      claude_pane="$ai2_pane"
    else
      tmux send-keys -t "$ai2_pane" "$ai2" C-m
    fi
  fi

  # Start nvim — if claude is involved, pass pane ID so claudecode.nvim auto-starts
  if [[ -n "$claude_pane" ]]; then
    tmux send-keys -t "$editor_pane" "TDL_CLAUDE_PANE=$claude_pane ${EDITOR:-nvim} ." C-m
  else
    tmux send-keys -t "$editor_pane" "${EDITOR:-nvim} ." C-m
  fi

  tmux select-pane -t "$editor_pane" -T "editor"
}
```

## 4. Usage

```bash
# Start tmux first
tmux

# Open a project with opencode + claude code (with nvim diff support)
cd ~/my-project
tdl c cx

# Layout:
# ┌──────────────┬────────────┐
# │              │  opencode  │
# │    nvim      ├────────────┤
# │              │ claude code│
# ├──────────────┴────────────┤
# │         terminal          │
# └───────────────────────────┘
```

## How the diff integration works

- `claudecode.nvim` starts a WebSocket server inside nvim
- When Claude Code launches (via `cx`), it gets the `CLAUDE_CODE_SSE_PORT` env var
- Claude Code connects to nvim over WebSocket
- When Claude suggests file changes, nvim opens a side-by-side diff
- `<leader>aa` — accept the diff (saves the file)
- `<leader>ad` — reject the diff

## Key bindings (from claudecode.nvim)

| Key          | Action                    |
|-------------|---------------------------|
| `<leader>ac` | Toggle Claude Code        |
| `<leader>af` | Focus Claude              |
| `<leader>ar` | Resume Claude             |
| `<leader>aa` | Accept diff               |
| `<leader>ad` | Deny diff                 |
| `<leader>ab` | Add current buffer        |
| `<leader>as` | Send selection + focus Claude (visual) |

## Key bindings (from tmux-chat.lua)

Sends `@file` or `@file:line-range` to the AI pane and focuses it.

| Key          | Action                          |
|-------------|----------------------------------|
| `<leader>io` | Send @file/selection to opencode |
| `<leader>ic` | Send @file/selection to claude   |
