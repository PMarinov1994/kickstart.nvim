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

vim.keymap.set('n', '<leader>fa', function()
  local windows = vim.api.nvim_tabpage_list_wins(0)

  ---@diagnostic disable-next-line: deprecated
  local lspClients = vim.lsp.get_active_clients()
  local lastClient = lspClients[#lspClients]

  local winId = nil
  if #windows < 2 then
    winId = windows[1]
  else
    winId = require('winpick').select()
  end

  if winId == nil then
    return
  end

  local bufNr = vim.api.nvim_win_get_buf(winId)
  vim.lsp.buf_attach_client(bufNr, lastClient.id)

  vim.notify('Attached buf: ' .. vim.api.nvim_buf_get_name(bufNr), vim.log.levels.INFO)
end, { desc = 'Attach current buffer to current lsp' })

vim.keymap.set('n', '<leader>fd', function()
  local windows = vim.api.nvim_tabpage_list_wins(0)

  ---@diagnostic disable-next-line: deprecated
  local lspClients = vim.lsp.get_active_clients()
  local lastClient = lspClients[#lspClients]

  local winId = nil
  if #windows < 2 then
    winId = windows[1]
  else
    winId = require('winpick').select()
  end

  if winId == nil then
    return
  end

  local bufNr = vim.api.nvim_win_get_buf(winId)
  vim.lsp.buf_detach_client(bufNr, lastClient.id)

  vim.notify('Detached buf: ' .. vim.api.nvim_buf_get_name(bufNr), vim.log.levels.INFO)
end, { desc = 'Detach current buffer to current lsp' })

vim.keymap.set('n', '<M-j>', '<cmd>cnext<CR>', { desc = 'Go to next Quick Fix line' })
vim.keymap.set('n', '<M-k>', '<cmd>cprev<CR>', { desc = 'Go to prev Quick Fix line' })

vim.keymap.set('n', '<Left>', ':vertical resize -2<CR>')
vim.keymap.set('n', '<Right>', ':vertical resize +2<CR>')
vim.keymap.set('n', '<Up>', ':resize +2<CR>')
vim.keymap.set('n', '<Down>', ':resize -2<CR>')

vim.keymap.set('n', '<leader>ft', floterminal.toggle_floterminal, { desc = 'Toggle floterminal' })

vim.keymap.set('n', 'q', '<nop>', {})
