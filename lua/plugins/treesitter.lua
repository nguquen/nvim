-- [[ treesitter.lua ]]

-- parsers to install; also the filetypes that get treesitter highlighting
local ts_files = {
  'lua',
  'rust',
  'javascript',
  'typescript',
  'yaml',
  'helm',
  'go',
  'java',
  'markdown',
  'json',
  'gitignore',
  'gitcommit',
}
require('nvim-treesitter').install(ts_files)
vim.api.nvim_create_autocmd('FileType', {
  pattern = ts_files,
  callback = function()
    -- the parser may not be compiled yet (first start, or no tree-sitter CLI);
    -- fall back to regex syntax highlighting instead of erroring
    pcall(vim.treesitter.start)
  end,
})
