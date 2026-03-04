-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Move buffer tabs left/right
vim.keymap.set("n", "<A-,>", ":BufferLineMovePrev<CR>", { silent = true })
vim.keymap.set("n", "<A-.>", ":BufferLineMoveNext<CR>", { silent = true })
