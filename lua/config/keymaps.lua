-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local telescope_ext = require 'config.telescope-ext'
local floterminal = require 'config.floterminal'

-- Disable line detele at cursor
vim.keymap.set('i', '<C-U>', '<nop>', {})
vim.keymap.set('v', '<leader>p', '"_dP', { noremap = true })
vim.keymap.set('n', '<leader>fy', '<cmd>let @+ = @%<cr>', { noremap = true, desc = "Yank current buff's relative path" })
vim.keymap.set('n', '<leader>fx', '<cmd>%!xxd<cr>', { noremap = true, desc = 'View current buff as hex' })
vim.keymap.set('n', '<leader>ff', telescope_ext.live_multigrep, { desc = 'Grep from selected files' })

vim.keymap.set('n', '<M-j>', '<cmd>cnext<CR>', { desc = 'Go to next Quick Fix line' })
vim.keymap.set('n', '<M-k>', '<cmd>cprev<CR>', { desc = 'Go to prev Quick Fix line' })

vim.keymap.set('n', '<Left>', ':vertical resize -2<CR>')
vim.keymap.set('n', '<Right>', ':vertical resize +2<CR>')
vim.keymap.set('n', '<Up>', ':resize +2<CR>')
vim.keymap.set('n', '<Down>', ':resize -2<CR>')

vim.keymap.set('n', '<leader>ft', floterminal.toggle_floterminal, { desc = 'Toggle floterminal' })
