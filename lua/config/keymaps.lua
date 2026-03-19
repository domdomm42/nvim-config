-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Paste over selection without losing clipboard
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Move lines up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true })

-- Centered half-page jumps
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Move buffer tabs left/right
vim.keymap.set("n", "<A-,>", ":BufferLineMovePrev<CR>", { silent = true })
vim.keymap.set("n", "<A-.>", ":BufferLineMoveNext<CR>", { silent = true })
