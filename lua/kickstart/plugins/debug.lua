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
    {
      'rcarriga/nvim-dap-ui',
      build = function()
        local patch_lua = os.getenv 'HOME' .. '/.local/share/nvim/lazy/nvim-dap-ui/lua/dapui/client/lib.lua'
        local file = io.open(patch_lua, 'r')
        if file then
          local content = file:read '*a'
          file:close()
          -- Replace the target string
          content = content:gsub(' or not vim%.uv%.fs_stat%(source%.path%) ', ' ')

          file = io.open(patch_lua, 'w')
          if file then
            file:write(content)
            file:close()
          end
        end
      end,
    },

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
    'theHamsta/nvim-dap-virtual-text',
    'mfussenegger/nvim-dap-python',

    -- My debuggers
    {
      'microsoft/vscode-js-debug',
      build = 'npm ci && npx gulp dapDebugServer && mv dist out',
    },
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
    {
      '<leader>k',
      function()
        ---@diagnostic disable-next-line: missing-fields
        require('dapui').eval(nil, { enter = true })
      end,
      desc = 'Debug: Show variable under cursor value',
    },
  },
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
        'codelldb',
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
      select_window = function()
        local windows = vim.tbl_filter(function(win)
          if vim.api.nvim_win_get_config(win).relative ~= '' then
            return false
          end
          local buf = vim.api.nvim_win_get_buf(win)
          local lsps_attached = vim.lsp.get_clients {
            bufnr = buf,
          }

          local buf_type = vim.api.nvim_get_option_value('buftype', {
            buf = buf,
          })

          return buf_type == '' or #lsps_attached > 0
        end, vim.api.nvim_tabpage_list_wins(0))

        return windows[1]
      end,
    }

    -- Change breakpoint icons
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }

    -- 💀 Make sure to update this path to point to your installation
    local debugger_path = os.getenv 'HOME' .. '/.local/share/nvim/lazy/vscode-js-debug' -- Path to vscode-js-debug installation.

    local vscode_launch_config_name = 'Launch VSCode Extension'
    -- NOTE: This requires the nvim to be opened inside the checkout folder
    -- i.e. 'nvim .' It will not work if you do 'nvim some/dir/path/source'
    local curr_dir = vim.fn.getcwd()

    dap.listeners.on_config['dap_vscode_launcher_hook'] = function(config)
      if config.name == vscode_launch_config_name then
        vim.system({
          'code',
          '--extensionDevelopmentPath=' .. curr_dir,
          '--inspect-extensions',
          '9229',
        }, {
          cwd = curr_dir,
        })
      end

      return config
    end

    dap.adapters['pwa-node'] = {
      type = 'server',
      host = 'localhost',
      port = 8123, -- default port for dapDebugServer
      executable = {
        command = 'node',
        args = {
          debugger_path .. '/out/src/dapDebugServer.js',
        },
      },
    }

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
          name = vscode_launch_config_name,
          cwd = '${workspaceFolder}',
          sourceMaps = true,
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

    require('nvim-dap-virtual-text').setup {
      enabled = false,
    }

    require('dap-python').setup 'python3'
  end,
}
