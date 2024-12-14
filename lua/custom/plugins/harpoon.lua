return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED

    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():add()
      local buf = vim.api.nvim_get_current_buf()
      vim.notify('Added file ' .. vim.api.nvim_buf_get_name(buf), vim.log.levels.INFO)
    end, { desc = 'Add buffer to harpoon' })

    vim.keymap.set('n', '<leader>r', function()
      harpoon:list():remove()
      local buf = vim.api.nvim_get_current_buf()
      vim.notify('Removed file ' .. vim.api.nvim_buf_get_name(buf), vim.log.levels.INFO)
    end, { desc = 'Remove buffer to harpoon' })

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<M-i>', function()
      harpoon:list():prev()
    end)
    vim.keymap.set('n', '<M-o>', function()
      harpoon:list():next()
    end)

    -- basic telescope configuration
    local conf = require('telescope.config').values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require('telescope.pickers')
        .new({}, {
          promt_title = 'Harpoon',
          finder = require('telescope.finders').new_table {
            results = file_paths,
          },
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter {},
        })
        :find()
    end

    vim.keymap.set('n', '<C-e>', function()
      toggle_telescope(harpoon:list())
    end, { desc = 'Open harpoon window' })
  end,
}
