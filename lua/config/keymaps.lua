-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Disable line detele at cursor
vim.api.nvim_set_keymap('i', '<C-U>', '<nop>', {})
--
vim.api.nvim_set_keymap('v', '<leader>p', '"_dP', { noremap = true })
--
vim.api.nvim_set_keymap('n', '<leader>fy', ':let @+ = @%<cr>', { noremap = true })
--
vim.api.nvim_set_keymap('n', '<leader>vx', ':%!xxd<cr>', { noremap = true })
--
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
-- vim.opt.relativenumber = true
