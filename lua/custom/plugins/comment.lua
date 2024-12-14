return {
  'terrortylor/nvim-comment',
  config = function()
    require('nvim_comment').setup {}
  end,
  keys = function()
    return {
      { '<leader>cl', ':CommentToggle<cr>', desc = 'Toggle Comment Block', mode = 'v' },
      { '<leader>cl', ':CommentToggle<cr>', desc = 'Toggle Comment Block', mode = 'n' },
    }
  end,
}
