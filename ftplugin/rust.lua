-- rustaceanvim starts rust-analyzer itself and merges vim.lsp.config['rust-analyzer'] into
-- its server config. This file is sourced before rustaceanvim's own ftplugin/rust.lua.
vim.lsp.config('rust-analyzer', {
  on_attach = require('config.lsp').format_on_attach,
  settings = {
    ['rust-analyzer'] = {
      imports = {
        granularity = {
          group = 'module',
        },
        prefix = 'crate',
      },
      cargo = {
        buildScripts = {
          enable = true,
        },
      },
      procMacro = {
        enable = true,
        attributes = {
          enable = true,
        },
        -- ignored = {
        --   ['async-trait'] = { 'async_trait' },
        -- },
      },
      diagnostics = {
        enable = true,
        -- disabled = { 'macro-error', 'proc-macro-disabled' },
        disabled = { 'proc-macro-disabled', 'inactive_code' },
        experimental = {
          enable = false,
        },
      },
    },
  },
})
