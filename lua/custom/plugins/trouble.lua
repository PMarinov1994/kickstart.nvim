vim.pack.add { 'https://github.com/folke/trouble.nvim' }

local map = vim.keymap.set

map('n', '<leader>xa', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Diagnostics (Trouble)' })

map('n', '<leader>xx', '<cmd>Trouble diagnostics toggle filter.severity=vim.diagnostic.severity.ERROR<cr>', { desc = 'Diagnostics Errors Only (Trouble)' })

map('n', '<leader>xw', '<cmd>Trouble diagnostics toggle filter.severity=vim.diagnostic.severity.WARN<cr>', { desc = 'Diagnostics Warning Only (Trouble)' })

map('n', '<leader>xc', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Buffer Diagnostics (Trouble)' })

map('n', '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', { desc = 'Symbols (Trouble)' })

map('n', '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', { desc = 'LSP Definitions / references / ... (Trouble)' })

map('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Location List (Trouble)' })

map('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quickfix List (Trouble)' })
