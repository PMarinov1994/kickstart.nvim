local install_path = vim.fn.stdpath 'data' .. '/tools/jdt-language-server-2.38.0-202408011337'

return {

  'mfussenegger/nvim-jdtls',
  build = function()
    -- Lua code to download and extract the external tool
    local url = 'https://www.eclipse.org/downloads/download.php?file=/jdtls/milestones/1.38.0/jdt-language-server-1.38.0-202408011337.tar.gz'
    local archive_name = 'jdt-language-server-1.38.0-202408011337.tar.gz'

    -- Create directory if does not exists
    vim.fn.system { 'mkdir', '-p', install_path }

    -- Download the archive
    vim.api.nvim_echo({
      {
        'Downloading ' .. archive_name,
        'DiagnosticInfo',
      },
    }, true, {})
    -- vim.notify('Downloading ' .. archive_name, vim.log.INFO)
    vim.fn.system { 'curl', '-L', '-o', install_path .. '/' .. archive_name, url }

    -- Extract the tar.gz file
    vim.api.nvim_echo({
      {
        'Extracting ' .. archive_name,
        'DiagnosticInfo',
      },
    }, true, {})
    -- vim.notify('Extracting ' .. archive_name, vim.log.INFO)
    vim.fn.system { 'tar', '-xzvf', install_path .. '/' .. archive_name, '-C', install_path }

    -- Delete the archive
    vim.fn.system { 'rm', install_path .. '/' .. archive_name }
  end,

  config = function()
    require('java').setup {
      -- Your custom jdls settings goes here
      cmd = { install_path .. '/jdtls' },
      root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
    }

    require('lspconfig').jdtls.setup {
      -- Your custom nvim-java configuration goes here
    }
  end,
}
