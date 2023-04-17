-- [[ plug.lua ]]

return require('packer').startup(function(use)
  -- packer can manage itself
  use 'wbthomason/packer.nvim'
  -- makes neovim faster
  use 'lewis6991/impatient.nvim'
  -- common
  use 'nvim-tree/nvim-web-devicons'
  use 'nvim-lua/plenary.nvim'
  use 'BurntSushi/ripgrep'
  use {
      'nvim-treesitter/nvim-treesitter',
      run = function()
          local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
          ts_update()
      end,
  }
  -- navigation
  use 'christoomey/vim-tmux-navigator'
  use 'nvim-tree/nvim-tree.lua'
  use 'nvim-telescope/telescope.nvim'
  -- mason
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  -- lsp
  use 'neovim/nvim-lspconfig'
  -- colorscheme
  use "rebelot/kanagawa.nvim"
  use "navarasu/onedark.nvim"
  -- status
  use 'nvim-lualine/lualine.nvim'
  -- editing
  use 'windwp/nvim-autopairs'
end)
