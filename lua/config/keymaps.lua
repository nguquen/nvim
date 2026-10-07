-- [[ keymaps.lua ]]
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

-- macros: record with Q (Qa … Q) so a stray q (a missed ]q / [q) doesn't start recording; Q: opens the
-- command-line window. Buffer-local q maps (plugins' "close") still win over this.
map('n', 'q', '<nop>', { noremap = true })
map('n', 'Q', 'q', { noremap = true })

-- misc
map('n', '<leader>ch', ':noh<cr>', { noremap = true, silent = true })
map('n', '<leader>p', '"0p', { noremap = true, silent = true })
-- read the system clipboard into register 0 (for <leader>p); needs a terminal that answers
-- OSC 52 reads, otherwise times out after 10 s (<C-c> cancels)
vim.keymap.set('n', '<leader>y', function()
  local lines = require('vim.ui.clipboard.osc52').paste('+')()
  if type(lines) == 'table' then
    vim.fn.setreg('0', lines)
  end
end, { silent = true })

-- refactoring.nvim: pick extract/inline variable or function; in normal mode, follow with a motion
vim.keymap.set({ 'n', 'x' }, '<leader>rf', function()
  require('refactoring').select_refactor()
end, { desc = 'Select refactor' })

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
vim.keymap.set('n', '<leader>\\', telescope_builtin.git_bcommits, {})
vim.keymap.set('n', 'gr', telescope_builtin.lsp_references, {})
vim.keymap.set('n', 'gi', telescope_builtin.lsp_implementations, {})
vim.keymap.set('n', 'gd', telescope_builtin.lsp_definitions, {})
vim.keymap.set('n', 'gD', telescope_builtin.lsp_type_definitions, {})

-- lsp
local function show_documentation()
  local filetype = vim.bo.filetype
  if vim.tbl_contains({ 'vim', 'help' }, filetype) then
    vim.cmd('h ' .. vim.fn.expand('<cword>'))
  elseif vim.tbl_contains({ 'man' }, filetype) then
    vim.cmd('Man ' .. vim.fn.expand('<cword>'))
  elseif vim.fn.expand('%:t') == 'Cargo.toml' and require('crates').popup_available() then
    require('crates').show_features_popup()
  else
    vim.lsp.buf.hover()
  end
end

-- jump to the previous/next diagnostic and show it in a float
local jump_diagnostic = function(count)
  return function()
    vim.diagnostic.jump({
      count = count,
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float({ bufnr = bufnr, scope = 'cursor', focus = false })
      end,
    })
  end
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'K', show_documentation, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<a-enter>', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '[d', jump_diagnostic(-1), opts)
    vim.keymap.set('n', ']d', jump_diagnostic(1), opts)
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

-- lazygit
-- map('n', '<leader>\\', ':LazyGit<cr>', {})

-- review: GitHub PRs (octo) and diffs (diffview)
vim.keymap.set('n', '<leader>rp', '<cmd>Octo pr list<cr>', { desc = 'List PRs' })
vim.keymap.set('n', '<leader>rd', '<cmd>PRDiff<cr>', { desc = 'Diffview PR' })
vim.keymap.set('n', '<leader>rr', '<cmd>Octo review start<cr>', { desc = 'Start review' })
vim.keymap.set('n', '<leader>rR', '<cmd>Octo review resume<cr>', { desc = 'Resume review' })
vim.keymap.set('n', '<leader>rs', '<cmd>Octo review submit<cr>', { desc = 'Submit review' })
-- in an Octo PR buffer, octo's buffer-local <leader>ra (lua/plugins/git.lua) approves that buffer's PR instead
vim.keymap.set('n', '<leader>ra', '<cmd>PRApprove<cr>', { desc = 'Approve the current branch\'s PR' })
vim.keymap.set('n', '<leader>rc', '<cmd>DiffviewClose<cr>', { desc = 'Close Diffview' })
vim.keymap.set('n', '<leader>rh', '<cmd>DiffviewFileHistory %<cr>', { desc = 'File history' })

-- ]c / [c: diff changes in diff mode, gitsigns hunks elsewhere
local jump_hunk = function(key, direction)
  return function()
    if vim.wo.diff then
      vim.cmd.normal({ vim.v.count1 .. key, bang = true })
    else
      require('gitsigns').nav_hunk(direction)
    end
  end
end
vim.keymap.set('n', ']c', jump_hunk(']c', 'next'), { desc = 'Next change / hunk' })
vim.keymap.set('n', '[c', jump_hunk('[c', 'prev'), { desc = 'Previous change / hunk' })
