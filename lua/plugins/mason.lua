-- [[ mason.lua ]] installs language servers and tools

require('mason').setup({
  ui = {
    icons = {
      package_installed = '✓',
      package_pending = '➜',
      package_uninstalled = '✗',
    },
  },
})

require('mason-lspconfig').setup({
  automatic_enable = false,
  -- every server with install = true in config/lsp.lua
  ensure_installed = vim
    .iter(require('config.lsp').servers)
    :filter(function(server)
      return server.install
    end)
    :map(function(server)
      return server.name
    end)
    :totable(),
})

require('mason-tool-installer').setup({
  ensure_installed = {
    'codelldb',
    'stylua',
    'prettierd',
    'eslint_d',
    'java-debug-adapter',
    'java-test',
    'debugpy',
    'delve',
    'js-debug-adapter',
    'sqlfluff',
    'npm-groovy-lint',
  },
})
