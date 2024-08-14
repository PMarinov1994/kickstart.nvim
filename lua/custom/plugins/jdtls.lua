return {
  'mfussenegger/nvim-jdtls',
  config = function()
    require('java').setup {
      -- Your custom jdls settings goes here
      cmd = { '~/Programs/jdt-language-server-1.38.0-202408011337/jdtls' },
      root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
    }

    require('lspconfig').jdtls.setup {
      -- Your custom nvim-java configuration goes here
    }
  end,
}
