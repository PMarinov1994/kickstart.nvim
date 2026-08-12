vim.pack.add { 'https://github.com/iamcco/markdown-preview.nvim' }

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'markdown-preview.nvim' then vim.system({ 'npm', 'install' }, { cwd = ev.data.path .. '/app' }):wait() end
  end,
})

vim.g.mkdp_filetypes = { 'markdown' }
