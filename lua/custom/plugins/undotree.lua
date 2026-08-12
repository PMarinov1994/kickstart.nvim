vim.pack.add { 'https://github.com/mbbill/undotree' }

vim.g.undotree_WindowLayout = 4

vim.keymap.set('n', '<leader>out', function() vim.cmd.UndotreeToggle() end, { desc = 'Open Undotree' })
