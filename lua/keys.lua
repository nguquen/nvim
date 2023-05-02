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
vim.keymap.set('n', '<leader>b', telescope_builtin.current_buffer_fuzzy_find, {})
vim.keymap.set('n', '<leader>rl', telescope_builtin.resume, {})
vim.keymap.set('n', '<leader>km', telescope_builtin.keymaps, {})
vim.keymap.set('n', '<leader>o', telescope_builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>d', telescope_builtin.diagnostics, {})
vim.keymap.set('n', '<leader>[', telescope_builtin.loclist, {})
vim.keymap.set('n', '<leader>]', telescope_builtin.quickfix, {})
vim.keymap.set('n', '<leader>\\', telescope_builtin.git_commits, {})
vim.keymap.set('n', 'gr', telescope_builtin.lsp_references, {})
vim.keymap.set('n', 'gi', telescope_builtin.lsp_implementations, {})
vim.keymap.set('n', 'gd', telescope_builtin.lsp_definitions, {})
vim.keymap.set('n', 'gD', telescope_builtin.lsp_type_definitions, {})

-- lsp
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<a-enter>', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  end,
})

-- nvim-dap
local dap = require('dap')
local dapui = require('dapui')
vim.keymap.set('n', '<f5>', dap.continue, {})
vim.keymap.set('n', '<f10>', dap.step_over, {})
vim.keymap.set('n', '<f11>', dap.step_into, {})
vim.keymap.set('n', '<f12>', dap.step_out, {})
vim.keymap.set('n', '<f9>', dap.toggle_breakpoint, {})
vim.keymap.set('n', '<s-f5>', dap.terminate, {})
vim.keymap.set('n', '<f2>', dapui.close, {})
