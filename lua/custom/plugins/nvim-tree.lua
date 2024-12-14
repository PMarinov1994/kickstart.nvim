return {
  'nvim-tree/nvim-tree.lua',
  version = '*',
  lazy = false,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('nvim-tree').setup {
      view = {
        adaptive_size = true,
        -- width = 10,
      },
    }
  end,
  keys = function()
    return {
      { '<leader>e', ':NvimTreeFindFileToggle<CR>', desc = 'File [e]xplorer tree toggle' },
      { '<leader>ecf', ':NvimTreeFindFile!<CR>', desc = 'File [e]xplorer go to [c]urrent [f]ile' },
    }
  end,
}
