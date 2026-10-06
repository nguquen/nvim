-- [[ pack.lua ]]

local gh = function(repo)
  return 'https://github.com/' .. repo
end

-- post-install/update hooks; must be registered before vim.pack.add() to see installs
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      require('nvim-treesitter').update()
    end
  end,
})

vim.pack.add({
  -- common
  gh('nvim-tree/nvim-web-devicons'),
  gh('nvim-lua/plenary.nvim'),
  gh('nvim-treesitter/nvim-treesitter'),
  -- navigation
  gh('christoomey/vim-tmux-navigator'),
  gh('nvim-tree/nvim-tree.lua'),
  gh('nvim-telescope/telescope.nvim'),
  gh('nvim-telescope/telescope-ui-select.nvim'),
  gh('natecraddock/telescope-zf-native.nvim'),
  gh('nvim-telescope/telescope-dap.nvim'),
  -- mason
  gh('williamboman/mason.nvim'),
  gh('williamboman/mason-lspconfig.nvim'),
  gh('WhoIsSethDaniel/mason-tool-installer.nvim'),
  -- colorscheme
  gh('rebelot/kanagawa.nvim'),
  gh('navarasu/onedark.nvim'),
  gh('rktjmp/lush.nvim'),
  gh('briones-gabriel/darcula-solid.nvim'),
  gh('MeanderingProgrammer/render-markdown.nvim'),
  gh('qvalentin/helm-ls.nvim'),
  -- status
  gh('nvim-lualine/lualine.nvim'),
  gh('arkav/lualine-lsp-progress'),
  -- editing
  gh('windwp/nvim-autopairs'),
  gh('folke/todo-comments.nvim'),
  { src = gh('faergeek/Comment.nvim'), version = 'nvim-0.12-compatibility' },
  gh('JoosepAlviste/nvim-ts-context-commentstring'),
  gh('jinh0/eyeliner.nvim'),
  gh('kylechui/nvim-surround'),
  gh('catgoose/nvim-colorizer.lua'),
  gh('uarun/vim-protobuf'),
  gh('lewis6991/gitsigns.nvim'),
  gh('kdheepak/lazygit.nvim'),
  { src = gh('f-person/git-blame.nvim'), version = 'main' },
  gh('maxmellon/vim-jsx-pretty'),
  gh('felpafel/inlay-hint.nvim'),
  gh('wakatime/vim-wakatime'),
  -- completion
  gh('hrsh7th/nvim-cmp'),
  gh('hrsh7th/cmp-nvim-lsp'),
  gh('hrsh7th/cmp-nvim-lsp-signature-help'),
  gh('hrsh7th/cmp-path'),
  gh('hrsh7th/cmp-buffer'),
  gh('hrsh7th/cmp-vsnip'),
  gh('hrsh7th/vim-vsnip'),
  gh('rcarriga/cmp-dap'),
  gh('rafamadriz/friendly-snippets'),
  gh('lukas-reineke/lsp-format.nvim'),
  gh('saecki/crates.nvim'),
  -- lsp
  gh('neovim/nvim-lspconfig'),
  gh('folke/lazydev.nvim'),
  gh('onsails/lspkind.nvim'),
  gh('mrcjkb/rustaceanvim'),
  gh('nvimtools/none-ls.nvim'),
  gh('nvimtools/none-ls-extras.nvim'),
  gh('mfussenegger/nvim-jdtls'),
  gh('lewis6991/async.nvim'), -- needed by refactoring.nvim on Neovim 0.12 (built in from 0.13)
  gh('ThePrimeagen/refactoring.nvim'),
  -- dap
  gh('nvim-neotest/nvim-nio'),
  gh('mfussenegger/nvim-dap'),
  gh('rcarriga/nvim-dap-ui'),
  gh('theHamsta/nvim-dap-virtual-text'),
  gh('mfussenegger/nvim-dap-python'),
  gh('leoluz/nvim-dap-go'),
  -- dadbod
  gh('tpope/vim-dotenv'),
  gh('tpope/vim-dadbod'),
  gh('kristijanhusak/vim-dadbod-ui'),
  gh('kristijanhusak/vim-dadbod-completion'),
  -- github
  gh('pwntester/octo.nvim'),
  gh('sindrets/diffview.nvim'),
})
