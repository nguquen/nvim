local map = vim.api.nvim_set_keymap

map('n', 'gd', '<Plug>(DBUI_JumpToForeignKey)', { noremap = true, silent = true })
