-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    -- 'mxsdev/nvim-dap-vscode-js',
    {
      'mxsdev/nvim-dap-vscode-js',
      dependencies = {
        {
          'microsoft/vscode-js-debug',
          build = 'npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out',
        },
      },
    },
  },
  keys = function(_, keys)
    local dap = require 'dap'
    local dapui = require 'dapui'
    return {
      -- Basic debugging keymaps, feel free to change to your liking!
      { '<F5>', dap.continue, desc = 'Debug: Start/Continue' },
      { '<F1>', dap.step_into, desc = 'Debug: Step Into' },
      { '<F2>', dap.step_over, desc = 'Debug: Step Over' },
      { '<F3>', dap.step_out, desc = 'Debug: Step Out' },
      { '<leader>b', dap.toggle_breakpoint, desc = 'Debug: Toggle Breakpoint' },
      {
        '<leader>B',
        function()
          dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Debug: Set Breakpoint',
      },
      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      { '<F7>', dapui.toggle, desc = 'Debug: See last session result.' },
      -- Terminate the active debug session
      {
        '<F4>',
        function()
          dap.disconnect { terminate = true }
          dap.close()
        end,
        desc = 'Debug: Terminate active session',
      },
      { '<leader>k', dapui.eval, desc = 'Debug: Show variable under cursor value' },
      unpack(keys),
    }
  end,

  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    ---@diagnostic disable: missing-fields
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }
    ---@diagnostic enable: missing-fields

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    ---@diagnostic disable: missing-fields
    require('dap-vscode-js').setup {
      -- node_path = 'node', -- Path of node executable. Defaults to $NODE_PATH, and then "node"
      -- Path to vscode-js-debug installation.
      -- debugger_path = '/home/plamen/git/vscode-js-debug',
      debugger_path = os.getenv 'HOME' .. '/.local/share/nvim/lazy/vscode-js-debug', -- Path to vscode-js-debug installation.
      -- debugger_cmd = { 'extension' }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
      -- which adapters to register in nvim-dap
      adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost', 'node', 'chrome' },
      -- log_file_path = '(stdpath cache)/dap_vscode_js.log', -- Path for file logging
      -- log_file_level = 0, -- Logging level for output to file. Set to false to disable file logging.
      -- log_console_level = vim.log.levels.ERROR, -- Logging level for output to console. Set to false to disable console output.
    }

    -- PM
    -- LLVM (Low Level Virtual Machine)
    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = { command = 'codelldb', args = { '--port', '${port}' } },
    }
    -- PM

    ---@diagnostic enable: missing-fields
    for _, language in ipairs { 'typescript', 'javascript' } do
      require('dap').configurations[language] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch TypeScript file (pwa-node)',
          program = '${file}',
          cwd = '${workspaceFolder}',
          runtimeExecutable = 'npx',
          runtimeArgs = { 'tsx' },
        },
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch JavaScript file (pwa-node)',
          program = '${file}',
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          skipFiles = { '<node_internals>/**' },
        },
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach',
          processId = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
        },
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Debug Jest Tests',
          -- trace = true, -- include debugger info
          runtimeExecutable = 'node',
          runtimeArgs = {
            './node_modules/jest/bin/jest.js',
            '--runInBand',
          },
          rootPath = '${workspaceFolder}',
          cwd = '${workspaceFolder}',
          console = 'integratedTerminal',
          internalConsoleOptions = 'neverOpen',
        },
      }
    end
  end,
}
