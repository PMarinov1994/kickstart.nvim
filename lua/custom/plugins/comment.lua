return {
  'terrortylor/nvim-comment',
  config = function()
    require('nvim_comment').setup {
      line_mapping = '<leader>cl',
    }
  end,
}
