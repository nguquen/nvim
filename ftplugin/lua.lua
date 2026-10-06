if vim.g.lazydev_setup_done then
  return
end
vim.g.lazydev_setup_done = true

-- Points lua_ls at Neovim's runtime and at the plugins each file require()s, as files are
-- opened. Skipped in projects with their own .luarc.json(c), so plain Lua projects keep
-- their own settings.
require('lazydev').setup({
  enabled = function(root_dir)
    return not (vim.uv.fs_stat(root_dir .. '/.luarc.json') or vim.uv.fs_stat(root_dir .. '/.luarc.jsonc'))
  end,
})
