-- [[ options.lua ]]

-- vim.g: maps to vim.api.nvim_set_var; sets global variables
local g = vim.g

-- no remote plugins are used, so skip loading (and health-checking) their providers
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0

-- to appropriately highlight codefences returned from denols
g.markdown_fenced_languages = {
  'ts=typescript',
}

-- with vim.opt we can set global, window and buffer settings, acting like :set in vimscript
local opt = vim.opt

-- [[ clipboard ]]
opt.clipboard = 'unnamedplus'
-- Copy to the system clipboard with OSC 52, but don't read it back: many terminals (and tmux)
-- don't answer OSC 52 reads, so every `p` would wait up to 10 s. `p` pastes what Neovim last
-- copied; paste from other apps with the terminal's paste shortcut, or `<leader>y`.
local osc52 = require('vim.ui.clipboard.osc52')
local last_copy = {}
local function copy(reg)
  local send = osc52.copy(reg)
  return function(lines, regtype)
    last_copy[reg] = { lines, regtype }
    send(lines)
  end
end
local function paste(reg)
  return function()
    return last_copy[reg] or { {}, 'v' }
  end
end
vim.g.clipboard = {
  name = 'OSC 52 (copy only)',
  copy = { ['+'] = copy('+'), ['*'] = copy('*') },
  paste = { ['+'] = paste('+'), ['*'] = paste('*') },
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
    -- Check for file changes; :checktime isn't allowed in command mode or the q: window
    if vim.fn.mode() ~= 'c' and vim.fn.getcmdwintype() == '' then
      vim.cmd('checktime')
    end
  end,
})

-- [[ filetypes ]]
opt.encoding = 'utf8'
opt.fileencoding = 'utf8'

-- [[ theme ]]
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
