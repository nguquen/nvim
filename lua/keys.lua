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
