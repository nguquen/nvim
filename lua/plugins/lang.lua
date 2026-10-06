-- [[ lang.lua ]] language plugins: Rust (rustaceanvim), Cargo.toml (crates), Helm

local format_on_attach = require('config.lsp').format_on_attach

-- rustaceanvim starts rust-analyzer itself, so it is configured here, not in after/lsp/
vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {},
  -- LSP configuration
  server = {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    on_attach = function(client)
      -- auto format
      format_on_attach(client)
    end,
    default_settings = {
      -- rust-analyzer language server configuration
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
  },
  -- DAP configuration
  dap = {},
}

require('crates').setup({
  lsp = {
    enabled = true,
    actions = true,
    completion = true,
    hover = true,
  },
})

require('helm-ls').setup({
  conceal_templates = {
    enabled = false,
  },
  indent_hints = {
    enabled = true,
    only_for_current_line = true,
  },
  action_highlight = {
    enabled = true,
  },
})
