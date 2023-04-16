-- [[ plug.lua ]]

return require('packer').startup(function(use)
  -- packer can manage itself
  use 'wbthomason/packer.nvim'
  -- mason
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  -- lsp
  use 'neovim/nvim-lspconfig'
  -- colorscheme
  use "rebelot/kanagawa.nvim"
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }
end)
