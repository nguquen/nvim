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
  -- every server enabled in config/lsp.lua, plus jdtls (started by ftplugin/java.lua)
  ensure_installed = vim.list_extend({ 'jdtls' }, require('config.lsp').servers),
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
  },
})
