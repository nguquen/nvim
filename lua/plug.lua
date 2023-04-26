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
  use 'WhoIsSethDaniel/mason-tool-installer.nvim'
  -- colorscheme
  use "rebelot/kanagawa.nvim"
  use "navarasu/onedark.nvim"
  -- status
  use 'nvim-lualine/lualine.nvim'
  -- editing
  use 'windwp/nvim-autopairs'
  use 'lewis6991/gitsigns.nvim'
  use 'folke/todo-comments.nvim'
  use 'folke/trouble.nvim'
  use 'numToStr/Comment.nvim'
  use 'JoosepAlviste/nvim-ts-context-commentstring'
  use 'jinh0/eyeliner.nvim'
  -- completion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-nvim-lua'
  use 'hrsh7th/cmp-nvim-lsp-signature-help'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'
  use 'rafamadriz/friendly-snippets'
  use 'lukas-reineke/lsp-format.nvim'
  -- lsp
  use 'neovim/nvim-lspconfig'
  use 'simrat39/rust-tools.nvim'
  use 'jose-elias-alvarez/null-ls.nvim'
end)
