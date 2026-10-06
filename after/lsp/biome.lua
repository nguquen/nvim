return {
  root_dir = function(bufnr, on_dir)
    -- Root at the nearest biome config. lspconfig's default roots at the nearest lockfile and
    -- doesn't look for a biome config above it, so a nested lockfile keeps biome from starting.
    local root = vim.fs.root(bufnr, { 'biome.json', 'biome.jsonc' })
    if root then
      on_dir(root)
    end
  end,
}
