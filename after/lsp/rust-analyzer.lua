-- rust-analyzer is started by rustaceanvim, not vim.lsp.enable(), so it isn't in config/lsp.lua's
-- server list. rustaceanvim merges this config (looked up by its client name, 'rust-analyzer')
-- into its own when it starts the client; on_attach here turns on format on save.
return {
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
}
