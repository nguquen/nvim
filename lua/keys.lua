-- [[ keys.lua ]]
local map = vim.api.nvim_set_keymap

-- disable arrow keys
map('n', '<Up>', '<NOP>', { noremap = true })
map('n', '<Down>', '<NOP>', { noremap = true })
map('n', '<Left>', '<NOP>', { noremap = true })
map('n', '<Right>', '<NOP>', { noremap = true })
map('i', '<Up>', '<NOP>', { noremap = true })
map('i', '<Down>', '<NOP>', { noremap = true })
map('i', '<Left>', '<NOP>', { noremap = true })
map('i', '<Right>', '<NOP>', { noremap = true })

-- save & edit
map('n', '<Leader>w', ':w<CR>', { noremap = true, silent = true })
map('n', '<Leader>q', ':q<CR>', { noremap = true, silent = true })
map('n', '<Leader>x', ':x<CR>', { noremap = true, silent = true })

-- navigation
map('n', '<Leader>h', '<C-W><C-H>', { noremap = true, silent = true })
map('n', '<Leader>j', '<C-W><C-J>', { noremap = true, silent = true })
map('n', '<Leader>k', '<C-W><C-K>', { noremap = true, silent = true })
map('n', '<Leader>l', '<C-W><C-L>', { noremap = true, silent = true })

-- misc
map('n', '<Leader>ch', ':noh<CR>', { noremap = true, silent = true })
map('n', '<Leader>p', '"0p', { noremap = true, silent = true })
map('n', '<Leader>y', ':let @0=@*<CR>', { noremap = true, silent = true })

-- nvim-tree
map('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- telescope
local telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', telescope_builtin.find_files, {})
vim.keymap.set('n', '<Leader>g', telescope_builtin.live_grep, {})
vim.keymap.set('n', '<Leader>b', telescope_builtin.buffers, {})
vim.keymap.set('n', '<Leader>[', telescope_builtin.loclist, {})
vim.keymap.set('n', '<Leader>]', telescope_builtin.quickfix, {})

-- lsp
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  end,
})
