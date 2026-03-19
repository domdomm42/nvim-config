-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable auto-commenting on new lines
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- Clean up swap file for the current buffer on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			local swapname = vim.api.nvim_buf_call(buf, function()
				return vim.fn.swapname("")
			end)
			if swapname and swapname ~= "" then
				os.remove(swapname)
			end
		end
	end,
})
