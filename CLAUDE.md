# Nvim Config - Claude Code Instructions

## Theme Setup

This config uses LazyVim. The active colorscheme is set via a theme plugin file.

### On Omarchy (Linux)

The theme is managed by omarchy's theme system. The file `~/.config/omarchy/current/theme/neovim.lua` is symlinked to `lua/plugins/theme.lua`. Do not create `lua/plugins/theme.lua` manually on Omarchy — it's handled automatically.

### On macOS (or any non-Omarchy system)

Create `lua/plugins/theme.lua` with the desired colorscheme config. This file is gitignored since it varies per machine.

#### Rose Pine (preferred)

```lua
return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    opts = {
      variant = "moon",
      disable_background = true,
      disable_float_background = true,
      styles = {
        italic = false,
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd.colorscheme("rose-pine-moon")
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine-moon",
    },
  },
}
```

For best results, set the terminal background to `#191724` (rose-pine base).

#### Vague

```lua
return {
  {
    "vague-theme/vague.nvim",
    priority = 1000,
    opts = {
      transparent = true,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vague",
    },
  },
}
```

### Available themes

All theme plugins are registered in `lua/plugins/all-themes.lua`. Any theme listed there can be activated by creating a `lua/plugins/theme.lua` that references it. To add a new theme, add it to `all-themes.lua` first, then reference it in `theme.lua`.

## Key Conventions

- `lua/plugins/theme.lua` — machine-specific, not committed (symlink on Omarchy, manual file on macOS)
- `lua/plugins/all-themes.lua` — all available theme plugins, committed
- `lua/config/keymaps.lua` — custom keybindings
- `lua/config/options.lua` — editor options
- `lua/config/autocmds.lua` — custom autocmds
- `plugin/after/transparency.lua` — strips backgrounds from UI elements for transparent look
