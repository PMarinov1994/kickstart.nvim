vim.pack.add { 'https://github.com/terrortylor/nvim-comment' }

vim.keymap.set({'n', 'v'}, '<leader>cl', vim.cmd.CommentToggle, { desc = 'Toggle Comment Block' })
