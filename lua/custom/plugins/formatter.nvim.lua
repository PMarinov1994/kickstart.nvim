return {
  'mhartington/formatter.nvim',
  config = function()
    require('formatter').setup {
      logging = true,
      log_level = vim.log.levels.WARN,
      filetype = {
        xml = {
          function()
            return {
              exe = 'tidy',
              args = {
                '-quiet',
                '-xml',
                '--indent yes',
                '--indent-spaces 2',
                '--sort-attributes alpha',
                '--wrap 0',
                '--indent-attributes 1',
              },
              stdin = true,
            }
          end,
        },
      },
    }
  end,
}
