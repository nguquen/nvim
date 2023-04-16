-- [[ init.lua ]]

-- impatient for faster loading
require('impatient')

-- leader; works across all nvim files
vim.g.mapleader = " "

-- ensure the packer plugin manager is installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- imports
require('vars') -- variables
require('opts') -- options
require('keys') -- keymaps
require('plug') -- plugins

-- the first run will install packer and our plugins
if packer_bootstrap then
  require("packer").sync()
  return
end

-- colorscheme
require('onedark').setup {
  style = 'dark',
  colors = {
    special_grey = "#3b4048",
  },
  highlights = {
    ["Whitespace"] = {fg = '$special_grey'},
  },
  lualine = {
    transparent = false,
  },
}
require('onedark').load()

-- lualine
require('lualine').setup {
  options = {
    theme = 'onedark',
  }
}

-- mason setup
require("mason").setup()
require("mason-lspconfig").setup()
