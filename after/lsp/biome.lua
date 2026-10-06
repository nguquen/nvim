return {
  root_dir = function(bufnr, on_dir)
    -- This repo has nested gitignored lockfiles (config/, config/opencode/)
    -- that shadow the real root. Trust the biome config file instead.
    local root = vim.fs.root(bufnr, { 'biome.json', 'biome.jsonc' })
    if root then
      on_dir(root)
    end
  end,
}
