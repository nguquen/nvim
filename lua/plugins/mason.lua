-- [[ mason.lua ]] installs language servers and tools; enabling servers is config/lsp.lua's job

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
  ensure_installed = {
    'lua_ls',
    'ts_ls',
    'jdtls',
    'gradle_ls',
    'gopls',
    'pyright',
    'ruff',
    'yamlls',
    'buf_ls',
    'prismals',
    'denols',
    'sqlls',
    'efm',
  },
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
    'taplo',
    'sqlfluff',
  },
})
