# Jupyter Notebook Setup for Neovim

The plugin config is already in `lua/plugins/jupyter.lua`. This guide sets up the Python environment needed to run it.

## Prerequisites

- `uv` (Python package manager) — install via `curl -LsSf https://astral.sh/uv/install.sh | sh`
- A terminal that supports Kitty graphics protocol (Ghostty, Kitty, WezTerm)

## Setup Steps

Run these commands in order:

```bash
# 1. Create a dedicated Python venv for Neovim's Jupyter support
uv venv ~/.local/share/nvim/jupyter-venv

# 2. Install all required Python packages
uv pip install --python ~/.local/share/nvim/jupyter-venv/bin/python \
  pynvim jupyter_client jupytext ipykernel nbformat \
  cairosvg pnglatex plotly kaleido

# 3. Symlink jupytext to PATH so the Neovim plugin can find it
ln -sf ~/.local/share/nvim/jupyter-venv/bin/jupytext ~/.local/bin/jupytext

# 4. Register a Jupyter kernel
~/.local/share/nvim/jupyter-venv/bin/python -m ipykernel install --user --name nvim-jupyter --display-name "Neovim Python"

# 5. Ensure the Jupyter runtime directory exists
mkdir -p ~/.local/share/jupyter/runtime
```

Then open Neovim and run:

```
:Lazy sync
:UpdateRemotePlugins
```

Quit and reopen Neovim.

## Usage

Open any `.ipynb` file — Jupytext auto-converts it to Python with `# %%` cell markers.

| Keymap         | Action                |
|----------------|-----------------------|
| `<leader>mi`   | Init/start kernel     |
| `<leader>ml`   | Run current line      |
| `<leader>me`   | Run visual selection  |
| `<leader>mr`   | Re-evaluate cell      |
| `<leader>mo`   | Show output           |
| `<leader>mh`   | Hide output           |
| `<leader>md`   | Delete cell output    |
