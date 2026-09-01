vim.pack.add { 'https://github.com/terrortylor/nvim-comment' }

require('nvim_comment').setup()
vim.keymap.set({ 'n', 'v' }, '<leader>cl', ':CommentToggle<CR>', { desc = 'Toggle Comment' })
