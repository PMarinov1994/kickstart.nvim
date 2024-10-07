return {
  'mfussenegger/nvim-jdtls',
  -- 'mfussenegger/nvim-dap',
  -- 'nvim-lua/plenary.nvim',
  -- {
  -- 'https://gitlab.com/schrieveslaach/nvim-jdtls-bundles',
  -- build = './install-bundles.py',
  -- },
  {
    'https://github.com/microsoft/java-debug',
    build = './mvnw clean install',
  },
  config = function()
    local jdtls = require 'jdtls'
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

    local bundles_path = vim.fn.expand '~/.vscode/extensions/yaozheng.vscode-pde-*/server'
    local bundles = {
      vim.fn.glob '~/.local/share/nvim/lazy/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar',
    }

    local scan = require 'plenary.scandir'
    scan.scan_dir(bundles_path, {
      hidden = true,
      depth = 2,
      on_insert = function(file)
        vim.list_extend(bundles, { file })
      end,
    })

    local config = {
      cmd = {
        -- 💀
        'java', -- or '/path/to/java17_or_newer/bin/java'
        -- depends on if `java` is in your $PATH env variable and if it points to the right version.

        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens',
        'java.base/java.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang=ALL-UNNAMED',

        -- 💀
        '-jar',
        vim.fn.expand '~/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar',
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
        -- Must point to the                                                     Change this to
        -- eclipse.jdt.ls installation                                           the actual version

        -- 💀
        '-configuration',
        vim.fn.expand '~/.local/share/nvim/mason/packages/jdtls/config_linux',
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
        -- Must point to the                      Change to one of `linux`, `win` or `mac`
        -- eclipse.jdt.ls installation            Depending on your system.

        -- 💀
        -- See `data directory configuration` section in the README
        '-data',
        vim.fn.expand '~/.cache/jdtls/workspace' .. project_name,
      },

      -- 💀
      -- This is the default if not provided, you can remove it. Or adjust as needed.
      -- One dedicated LSP server & client will be started per unique root_dir
      -- root_dir = require('jdtls.setup').find_root { 'pom.xml' },

      -- Here you can configure eclipse.jdt.ls specific settings
      -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
      -- for a list of options
      settings = {
        java = {
          references = {
            includeDecompiledSources = true,
          },
          -- format = {
          --   enabled = true,
          --   settings = {
          --     url = '/media/pmarinov/HDD/HilscherProjects/netXStudio_cdt/javaFormatter/code_style_formatter.xml',
          --     profile = 'HilscherStyle',
          --   },
          -- },
        },
      },

      -- Language server `initializationOptions`
      -- You need to extend the `bundles` with paths to jar files
      -- if you want to use additional eclipse.jdt.ls plugins.
      --
      -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
      --
      -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
      init_options = {
        bundles = bundles,
      },
      capabilities = capabilities,
    }

    local existsInCWD = function(nameToCheck)
      local cwdDir = vim.fn.getcwd()

      -- Get all files and directories in CWD
      local cwdContent = vim.split(vim.fn.glob(cwdDir .. '/*'), '\n', { trimempty = true })

      local fullNameToCheck = cwdDir .. '/' .. nameToCheck
      for _, cwdItem in pairs(cwdContent) do
        if cwdItem == fullNameToCheck then
          return true
        end
      end
      return false
    end

    -- if existsInCWD 'javaConfig.json' then
    -- vim.notify('Loading jdtls!', vim.log.levels.INFO)
    -- This starts a new client & server
    -- or attaches to an existing client & secter depending on the 'root_dir'
    -- jdtls.start_or_attach(config)
    -- end

    jdtls.start_or_attach(config)
  end,

  -- keys = function(_, keys)
  --   local util = require 'jdtls.util'
  --   return {
  --     {
  --       '<leader>rtp',
  --       function()
  --         util.execute_command({
  --           command = 'java.pde.reloadTargetPlatform',
  --           arguments = '/home/pmarinov/BitBucket/netx.studio.eclipse/Product/com.hilscher.netxstudio.target/com.hilscher.netxstudio.target.target',
  --         }, function(err)
  --           assert(not err, vim.inspect(err))
  --         end, nil)
  --       end,
  --       desc = '[r]eload [t]arget [p]latform',
  --     },
  --     unpack(keys),
  --   }
  -- end,
}
