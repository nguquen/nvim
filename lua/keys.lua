-- [[ keys.lua ]]
local map = vim.api.nvim_set_keymap

-- disable arrow keys
map('n', '<up>', '<nop>', { noremap = true })
map('n', '<down>', '<nop>', { noremap = true })
map('n', '<left>', '<nop>', { noremap = true })
map('n', '<right>', '<nop>', { noremap = true })
map('i', '<up>', '<nop>', { noremap = true })
map('i', '<down>', '<nop>', { noremap = true })
map('i', '<left>', '<nop>', { noremap = true })
map('i', '<right>', '<nop>', { noremap = true })

-- save & edit
map('n', '<leader>w', ':w<cr>', { noremap = true, silent = true })
map('n', '<leader>q', ':q<cr>', { noremap = true, silent = true })
map('n', '<leader>x', ':x<cr>', { noremap = true, silent = true })

-- navigation
map('n', '<leader>h', '<c-w><c-h>', { noremap = true, silent = true })
map('n', '<leader>j', '<c-w><c-j>', { noremap = true, silent = true })
map('n', '<leader>k', '<c-w><c-k>', { noremap = true, silent = true })
map('n', '<leader>l', '<c-w><c-l>', { noremap = true, silent = true })

-- misc
map('n', '<leader>ch', ':noh<cr>', { noremap = true, silent = true })
map('n', '<leader>p', '"0p', { noremap = true, silent = true })
map('n', '<leader>y', ':let @0=@*<cr>', { noremap = true, silent = true })

-- nvim-tree
map('n', '<C-n>', ':NvimTreeToggle<cr>', { noremap = true, silent = true })

-- telescope
local telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<c-p>', telescope_builtin.find_files, {})
vim.keymap.set('n', '<leader>g', telescope_builtin.live_grep, {})
vim.keymap.set('n', '<leader>s', telescope_builtin.grep_string, {})
vim.keymap.set('n', '<leader>b', telescope_builtin.buffers, {})
vim.keymap.set('n', '<leader>rl', telescope_builtin.resume, {})
vim.keymap.set('n', '<leader>km', telescope_builtin.keymaps, {})
vim.keymap.set('n', '<leader>o', telescope_builtin.lsp_document_symbols, {})

-- lsp
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<a-enter>', vim.lsp.buf.code_action, opts)
  end,
})

-- trouble
vim.keymap.set('n', '<leader>d', '<cmd>TroubleToggle workspace_diagnostics<cr>', { silent = true, noremap = true })
vim.keymap.set('n', '<leader>[', '<cmd>TroubleToggle loclist<cr>', { silent = true, noremap = true })
vim.keymap.set('n', '<leader>]', '<cmd>TroubleToggle quickfix<cr>', { silent = true, noremap = true })
vim.keymap.set('n', 'gr', '<cmd>TroubleToggle lsp_references<cr>', { silent = true, noremap = true })
