-- Custom keymaps

return {

  config = function()
    -- NOTE Custom random keybinds go here
    --
    -- Disable line detele at cursor
    vim.keymap.set('i', '<C-U>', '<nop>')
    --
    vim.keymap.set('v', '<leader>p', '"_dP', { noremap = true })
    --
  end,
}
