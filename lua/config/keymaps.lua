-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

print 'TTTTTTTTTTTTTTTT'
-- Disable line detele at cursor
vim.api.nvim_set_keymap('i', '<C-U>', '<nop>', {})
--
vim.api.nvim_set_keymap('v', '<leader>p', '"_dP', { noremap = true })
--
