return {
  'PMarinov1994/harpoon',
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
      vim.notify('Harpoon add ' .. vim.api.nvim_buf_get_name(buf), vim.log.levels.INFO)
    end, { desc = 'Add buffer to harpoon' })

    vim.keymap.set('n', '<leader>r', function()
      harpoon:list():remove()
      harpoon:list():remove_empty_entries()
      local buf = vim.api.nvim_get_current_buf()
      vim.notify('Harpoon remove ' .. vim.api.nvim_buf_get_name(buf), vim.log.levels.INFO)
    end, { desc = 'Remove buffer to harpoon' })

    vim.keymap.set('n', '<leader>r', function()
      harpoon:list():clear()
      vim.notify('Harpoon clear all', vim.log.levels.INFO)
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
      local make_finder = function()
        local file_paths = {}
        for _, item in pairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        return require('telescope.finders').new_table {
          results = file_paths,
        }
      end

      require('telescope.pickers')
        .new({}, {
          promt_title = 'Harpoon',
          finder = make_finder(),
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter {},
          attach_mappings = function(prompt_buffer_number, map)
            map('n', 'd', function()
              local state = require 'telescope.actions.state'
              local selected_entry = state.get_selected_entry()
              local current_picker = state.get_current_picker(prompt_buffer_number)

              harpoon:list():remove(selected_entry)
              harpoon:list():remove_empty_entries()
              current_picker:refresh(make_finder())
            end)

            return true
          end,
        })
        :find()
    end

    vim.keymap.set('n', '<C-e>', function()
      toggle_telescope(harpoon:list())
    end, { desc = 'Open harpoon window' })
  end,
}
