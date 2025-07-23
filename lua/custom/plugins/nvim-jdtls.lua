-- local curr_dir = vim.fn.getcwd()
local curr_dir = vim.fn.expand '%:p:h'

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local project_name = vim.fn.fnamemodify(curr_dir, ':p:h:t')
local workspace_folder = vim.fn.expand '~/.cache/jdtls/workspace.' .. project_name

-- Healper function
local existsInCWD = function(nameToCheck)
  local cwdContent = vim.split(vim.fn.glob(curr_dir .. '/*'), '\n', { trimempty = true })
  local fullNameToCheck = curr_dir .. '/' .. nameToCheck
  for _, cwdItem in pairs(cwdContent) do
    if cwdItem == fullNameToCheck then
      return true
    end
  end
  return false
end

-- a function that returns an array with changed items based on some function
local map = function(tbl, f)
  local t = {}
  for k, v in pairs(tbl) do
    t[k] = f(v)
  end
  return t
end

local function pick_projects(callback)
  local util = require 'jdtls.util'

  util.execute_command({
    command = 'java.project.getAll',
  }, function(err, resp)
    assert(not err, vim.inspect(err))

    local projects = resp
    if projects and projects[1] then
      callback(vim.fn.fnamemodify(projects[1], ':h:t'))
    else
      callback(nil)
    end
  end)
end

-- Based on the passed *.launch file
-- 1. Start Debug Server
-- 2. Extract launch parameters
-- 3. Setup dap.configurations.java
-- 4. Setup dap.adapters.java
-- 5. TODO start the debug configuration
local launch_debug = function(launch_file)
  local util = require 'jdtls.util'

  local status, dap = pcall(require, 'dap')
  if not status then
    print 'nvim-dap is not available'
    return
  end

  dap.set_log_level 'TRACE'

  util.execute_command({ command = 'vscode.java.startDebugSession' }, function(err, port)
    assert(not err, vim.inspect(err))

    util.execute_command({
      command = 'java.pde.resolveLaunchArguments',
      arguments = 'file:' .. curr_dir .. '/' .. launch_file,
    }, function(laError, launchArgs)
      assert(not laError, vim.inspect(laError))

      local escapeStringsInList = function(item)
        return '"' .. item .. '"'
      end

      pick_projects(function(projectName)
        -- TODO append to configuration instead of overriding
        dap.configurations.java = {
          {
            type = 'java',
            name = 'Debug Eclipse launch',
            request = 'launch',

            projectName = projectName or project_name,
            mainClass = 'org.eclipse.equinox.launcher.Main',
            classPaths = launchArgs.classpath,
            vmArgs = table.concat(map(launchArgs.vmArguments, escapeStringsInList), ' '),
            args = table.concat(map(launchArgs.programArguments, escapeStringsInList), ' '),
            env = launchArgs.environment,
          },
        }

        dap.adapters.java = {
          type = 'server',
          host = 'localhost',
          port = port,
        }

        --
        -- To view the log:
        -- :lua print(vim.fn.stdpath('cache'))
        -- The filename is `dap.log`
        dap.run(dap.configurations.java[1], { new = true, filetype = 'java' })
      end)

      --
    end, nil) -- util.execute_command({
  end, nil) -- util.execute_command({ command = 'vscode.java.startDebugSession' }, function(err, port)
end -- local launch_debug = function(launch_file)

local pick_launch = function(title, filter, on_pick)
  pickers
    .new({}, {
      prompt_title = title,
      finder = finders.new_oneshot_job({ 'rg', '--files', '--glob', filter }, {
        cwd = curr_dir,
      }),
      attach_mappings = function(buffer_number)
        actions.select_default:replace(function()
          actions.close(buffer_number)
          on_pick(action_state.get_selected_entry()[1])
        end)
        return true
      end,
    })
    :find()
end -- local pick_launch = function(cwd)

--
local get_value_from_javaConfig = function(key)
  local filePath = curr_dir .. '/javaConfig.json'
  if not vim.uv.fs_stat(filePath) then
    return nil
  end

  local lines = {}
  for line in io.lines(filePath) do
    if not vim.startswith(vim.trim(line), '//') then
      table.insert(lines, line)
    end
  end
  local jsonContent = table.concat(lines, '\n')

  local ok, data = pcall(vim.json.decode, jsonContent)
  if not ok then
    error('Error parsing launch.json: ' .. data)
  end

  return data[key]
end

return {
  'mfussenegger/nvim-jdtls',
  dependencies = {
    'nvim-dap',
    {
      'microsoft/java-debug',
      build = './mvnw clean install',
    },
    {
      'eclipse-jdtls/eclipse.jdt.ls',
      branch = 'main',
      build = './mvnw clean verify -DskipTests=true',
    },
    {
      'PMarinov1994/vscode-pde',
      build = 'npm ci && npx gulp full_build',
    },
  },
  ft = { 'java' },
  config = function()
    local jdtls = require 'jdtls'

    local extendedClientCapabilities = jdtls.extendedClientCapabilities
    extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

    local lazy_dir = vim.fn.stdpath 'data' .. '/lazy'
    local bundles = {
      vim.fn.glob(lazy_dir .. '/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar', true),
    }

    local vscode_pde_server_path = lazy_dir .. '/vscode-pde/server'
    local vscode_pde_server_jars = vim.split(vim.fn.glob(vscode_pde_server_path .. '/*.jar', true), '\n')
    vim.list_extend(bundles, vscode_pde_server_jars)

    local eclipse_jdtls_dir = lazy_dir .. '/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository'

    -- vim.notify(vim.inspect(bundles), vim.log.levels.ERROR)

    --  local scan = require 'plenary.scandir'
    --  scan.scan_dir(bundles_path, {
    --    hidden = true,
    --    depth = 2,
    --    on_insert = function(file)
    --      vim.list_extend(bundles, { file })
    --    end,
    --  })

    local config = {
      name = curr_dir,
      on_attach = function(_, _)
        jdtls.setup_dap {
          -- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
          -- you make during a debug session immediately.
          -- Remove the option if you do not want that.
          hotcodereplace = 'auto',
          config_overrides = {},
        }
      end,
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
        vim.fn.glob(eclipse_jdtls_dir .. '/plugins/org.eclipse.equinox.launcher_*.jar', true),
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
        -- Must point to the                                                     Change this to
        -- eclipse.jdt.ls installation                                           the actual version

        -- 💀
        '-configuration',
        eclipse_jdtls_dir .. '/config_linux',
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
        -- Must point to the                      Change to one of `linux`, `win` or `mac`
        -- eclipse.jdt.ls installation            Depending on your system.

        -- 💀
        -- See `data directory configuration` section in the README
        '-data',
        workspace_folder,
      },

      -- 💀
      -- This is the default if not provided, you can remove it. Or adjust as needed.
      -- One dedicated LSP server & client will be started per unique root_dir
      root_dir = vim.fs.root(0, { '.git', 'mvnw', 'gradlew', 'javaConfig.json' }),

      -- Here you can configure eclipse.jdt.ls specific settings
      -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
      -- for a list of options
      settings = {
        java = {
          inlay_hint = {
            parameterNames = {
              enabled = 'all',
            },
          },
          eclipse = {
            downloadSources = true,
          },
          maven = {
            downloadSources = true,
          },
          implementationsCodeLens = {
            enabled = true,
          },
          referencesCodeLens = {
            enabled = true,
          },
          references = {
            includeDecompiledSources = true,
          },
          format = {
            enabled = true,
            settings = {
              url = vim.fn.stdpath 'config' .. '/java_formatter/code_style_formatter.xml',
              -- profile = 'HilscherStyle',
            },
          },
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
      extendedClientCapabilities = extendedClientCapabilities,
      capabilities = nil,
    }

    -- Start the server if the root folder contains javaConfig.json
    -- This will speed up the loading of the target platform. Otherwise
    -- we start the server when a Java file is opened.
    if existsInCWD 'javaConfig.json' then
      jdtls.start_or_attach(config)
    end

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'java',
      callback = function()
        jdtls.start_or_attach(config)
      end,
    })
  end,

  keys = function(_, _)
    local util = require 'jdtls.util'
    return {
      {
        '<leader>rtp',
        function()
          pick_launch('Path to target', '**.target', function(file)
            util.execute_command({
              command = 'java.pde.reloadTargetPlatform',
              arguments = 'file://' .. curr_dir .. '/' .. file,
            }, function(err)
              assert(not err, vim.inspect(err))
            end, nil)
          end)
        end,
        desc = '[r]eload [t]arget [p]latform',
      },
      {
        '<leader>dtp',
        function()
          local storedLaunch = get_value_from_javaConfig 'pde_launch'
          if storedLaunch == nil then
            pick_launch('Path to executable', '**.launch', function(file)
              launch_debug(file)
            end)
          else
            launch_debug(storedLaunch)
          end -- if storedLaunch == nil then
        end, -- function shortcut
        desc = '[d]ebug [t]arget [p]latform',
      },
      {
        '<leader>cwf',
        function()
          local scan = require 'plenary.scandir'
          scan.scan_dir(workspace_folder, {
            hidden = false,
            add_dirs = true,
            depth = 1,
            on_insert = function(file)
              local clear_result = vim.fn.delete(file, 'rf')
              assert(clear_result == 0, 'Failed to delete item: ' .. workspace_folder)
              vim.notify('Deleted: ' .. file, vim.log.levels.INFO)
            end,
          })
        end, -- function shortcut
        desc = '[c]lear [w]orkspace [f]older',
      },
    }
  end,
}
