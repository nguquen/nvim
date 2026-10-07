-- [[ init.lua ]]

-- cache compiled lua modules for faster loading
vim.loader.enable()

-- leader; works across all nvim files
vim.g.mapleader = ' '

require('config.options')
require('config.pack') -- installs missing plugins on first start; everything below can use them
require('config.keymaps')

require('plugins.ui')
require('plugins.navigation')
require('plugins.editing')
require('plugins.git')
require('config.lsp')
require('plugins.mason')
require('plugins.dap')
require('plugins.completion')
require('plugins.treesitter')
require('plugins.db')
require('plugins.wakatime')
