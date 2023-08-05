local map = vim.api.nvim_set_keymap

map('n', 'dw', '<Plug>(DBUI_SaveQuery)', { noremap = true, silent = true })
