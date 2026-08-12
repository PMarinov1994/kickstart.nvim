vim.pack.add {
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/nvim-tree/nvim-web-devicons',
}

require('nvim-tree').setup {
  view = {
    adaptive_size = true,
    -- width = 10,
  },
  renderer = {
    root_folder_label = ':t', -- show only the tail (folder name) of the path
  },
}

vim.keymap.set('n', '<leader>e', vim.cmd.NvimTreeFindFileToggle, { desc = 'File [e]xplorer tree toggle' })
vim.keymap.set('n', '<leader>ecf', vim.cmd.NvimTreeFindFile, { desc = 'File [e]xplorer go to [c]urrent [f]ile' })
