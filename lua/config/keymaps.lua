-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local telescope_ext = require 'config.telescope-ext'
local floterminal = require 'config.floterminal'

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

-- Disable line detele at cursor
vim.keymap.set('i', '<C-U>', '<nop>', {})
vim.keymap.set('v', '<leader>p', '"_dP', { noremap = true })
vim.keymap.set('c', '<C-v>', '<C-r>+', { noremap = true })
vim.keymap.set('n', '<leader>fy', '<cmd>let @+ = @%<cr>', { noremap = true, desc = "Yank current buff's relative path" })
vim.keymap.set('n', '<leader>fx', '<cmd>%!xxd<cr>', { noremap = true, desc = 'View current buff as hex' })
vim.keymap.set('n', '<leader>ff', telescope_ext.live_multigrep, { desc = 'Grep from selected files' })

vim.keymap.set('n', '<leader>fa', function()
  local windows = vim.api.nvim_tabpage_list_wins(0)

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

  local function detach_lsp_client_from_buf(targetClient)
    vim.lsp.buf_attach_client(bufNr, targetClient.id)
    vim.notify('Attached buf: ' .. vim.api.nvim_buf_get_name(bufNr), vim.log.levels.INFO)
  end

  ---@diagnostic disable-next-line: deprecated
  local lspClients = vim.lsp.get_active_clients()
  if #lspClients < 2 then
    detach_lsp_client_from_buf(lspClients[1])
  else
    pickers
      .new({}, {
        prompt_title = 'Select LPS Client',
        finder = finders.new_table {
          results = lspClients,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.name,
              ordinal = entry.name,
            }
          end,
        },
        attach_mappings = function(buffer_number)
          actions.select_default:replace(function()
            actions.close(buffer_number)
            local targetClient = action_state.get_selected_entry()
            detach_lsp_client_from_buf(targetClient.value)
          end)
          return true
        end,
      })
      :find()
    return
  end
end, { desc = 'Attach current buffer to current lsp' })

vim.keymap.set('n', '<leader>fd', function()
  local windows = vim.api.nvim_tabpage_list_wins(0)

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

  local function detach_lsp_client_from_buf(targetClient)
    vim.lsp.buf_detach_client(bufNr, targetClient.id)
    vim.notify('Detached buf: ' .. vim.api.nvim_buf_get_name(bufNr), vim.log.levels.INFO)
  end

  ---@diagnostic disable-next-line: deprecated
  local lspClients = vim.lsp.get_active_clients {
    bufnr = bufNr,
  }

  if #lspClients < 2 then
    detach_lsp_client_from_buf(lspClients[1])
  else
    -- NOTE:May never get here since buffer can have one lsp attached but meh...
    pickers
      .new({}, {
        prompt_title = 'Select LPS Client',
        finder = finders.new_table {
          results = lspClients,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.name,
              ordinal = entry.name,
            }
          end,
        },
        attach_mappings = function(buffer_number)
          actions.select_default:replace(function()
            actions.close(buffer_number)
            local targetClient = action_state.get_selected_entry()
            detach_lsp_client_from_buf(targetClient)
          end)
          return true
        end,
      })
      :find()
    return
  end
end, { desc = 'Detach current buffer to current lsp' })

vim.keymap.set('n', '<M-j>', '<cmd>cnext<CR>', { desc = 'Go to next Quick Fix line' })
vim.keymap.set('n', '<M-k>', '<cmd>cprev<CR>', { desc = 'Go to prev Quick Fix line' })

vim.keymap.set('n', '<Left>', ':vertical resize -2<CR>')
vim.keymap.set('n', '<Right>', ':vertical resize +2<CR>')
vim.keymap.set('n', '<Up>', ':resize +2<CR>')
vim.keymap.set('n', '<Down>', ':resize -2<CR>')

vim.keymap.set('n', '<leader>ft', floterminal.toggle_floterminal, { desc = 'Toggle floterminal' })

vim.keymap.set('n', 'q', '<nop>', {})
