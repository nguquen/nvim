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
