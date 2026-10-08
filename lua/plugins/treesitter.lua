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
  'html', -- also used by render-markdown for HTML inside markdown
  'json',
  'gitignore',
  'gitcommit',
}
require('nvim-treesitter').install(ts_files)

-- Octo PR / issue buffers are markdown (the parser is looked up by filetype, also by render-markdown, which needs the
-- highlighter running for its conceals)
vim.treesitter.language.register('markdown', 'octo')

vim.api.nvim_create_autocmd('FileType', {
  pattern = vim.list_extend({ 'octo' }, ts_files),
  callback = function(ev)
    -- the parser may not be compiled yet (first start, or no tree-sitter CLI);
    -- fall back to regex syntax highlighting instead of erroring
    pcall(vim.treesitter.start)
    if ev.match == 'octo' then
      -- keep Octo's syntax file too (turned off by vim.treesitter.start): it conceals :heart: etc. as emoji
      vim.bo[ev.buf].syntax = 'ON'
    end
  end,
})
