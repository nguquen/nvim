-- [[ opts.lua ]]

-- with vim.opt we can set global, window and buffer settings, acting like :set in vimscript
local opt = vim.opt

-- [[ clipboard ]]
opt.clipboard = 'unnamedplus'
-- opt.pastetoggle = '<F2>'
---@diagnostic disable-next-line: inject-field
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}

-- [[ editor ]]
opt.updatetime = 300
opt.signcolumn = 'yes'
opt.number = true
opt.relativenumber = true
opt.visualbell = true
opt.listchars = 'eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:·'
opt.list = true
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.splitbelow = true
opt.splitright = true
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - { 'c', 'r', 'o' }
  end,
})
opt.autoread = true
vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'CursorHoldI', 'FocusGained', 'TermLeave', 'WinEnter' }, {
  group = vim.api.nvim_create_augroup('CheckForExternalChanges', { clear = true }),
  callback = function()
    -- Check for file changes, but only if not in command mode
    if vim.fn.mode() ~= 'c' then
      vim.cmd('checktime')
    end
  end,
})

-- [[ filetypes ]]
opt.encoding = 'utf8'
opt.fileencoding = 'utf8'

-- [[ theme ]]
opt.syntax = 'ON'
opt.termguicolors = true

-- [[ lsp diagnostic ]]
vim.diagnostic.config({
  virtual_text = false,
  update_in_insert = true,
  underline = true,
  severity_sort = false,
  float = {
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.HINT] = '💡',
      [vim.diagnostic.severity.INFO] = '',
    },
  },
})

-- [[ completion ]]
-- completeopt is used to manage code suggestions
-- menuone: show popup even when there is only one suggestion
-- noinsert: Only insert text when selection is confirmed
-- noselect: force us to select one from the suggestions
opt.completeopt = { 'menuone', 'noselect', 'noinsert' }
opt.shortmess = vim.opt.shortmess + { c = true }
vim.api.nvim_create_autocmd('CursorHold', {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
})

-- [[ treesitter ]]
-- vim.wo.foldmethod = 'expr'
-- vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
