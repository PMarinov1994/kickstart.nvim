return {
  'mbbill/undotree',
  config = function()
    vim.g.undotree_WindowLayout = 4
  end,
  keys = {
    {
      '<leader>out',
      function()
        vim.cmd.UndotreeToggle()
      end,
      desc = 'Open Undotree',
    },
  },
}
