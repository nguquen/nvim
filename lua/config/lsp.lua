-- [[ lsp.lua ]]
-- Shared LSP setup. Per-server settings live in after/lsp/<server>.lua (after/, so they
-- override nvim-lspconfig's lsp/<server>.lua defaults). Buffer keymaps are in config/keymaps.lua.
local M = {}

require('lsp-format').setup({})

-- format on save through lsp-format; also used by none-ls and after/lsp/rust-analyzer.lua
M.format_on_attach = function(client)
  require('lsp-format').on_attach(client)
end

vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- servers to run (lspconfig names); plugins/mason.lua installs each one that's missing.
-- Rust and Java start their own servers: see after/lsp/rust-analyzer.lua and ftplugin/java.lua.
M.servers = {
  { name = 'biome', format_on_save = true },
  { name = 'buf_ls', format_on_save = true },
  { name = 'denols', format_on_save = false },
  { name = 'efm', format_on_save = true },
  { name = 'gopls', format_on_save = true },
  { name = 'gradle_ls', format_on_save = false },
  { name = 'helm_ls', format_on_save = false },
  { name = 'jsonls', format_on_save = false },
  { name = 'lua_ls', format_on_save = false }, -- stylua (none-ls) formats Lua
  { name = 'prismals', format_on_save = true },
  { name = 'pyright', format_on_save = false },
  { name = 'ruff', format_on_save = true },
  { name = 'sqlls', format_on_save = false }, -- sqlfluff (none-ls) formats SQL
  { name = 'taplo', format_on_save = true },
  { name = 'ts_ls', format_on_save = false }, -- consider https://github.com/pmizio/typescript-tools.nvim
  { name = 'yamlls', format_on_save = true },
}

for _, server in ipairs(M.servers) do
  if server.format_on_save then
    vim.lsp.config(server.name, { on_attach = M.format_on_attach })
  end
  vim.lsp.enable(server.name)
end

-- inlay hints for servers that support them
require('inlay-hint').setup()
vim.api.nvim_create_autocmd({ 'LspAttach', 'LspDetach' }, {
  callback = function(args)
    local bufnr = args.buf ---@type number
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    local inlayHintProvider = client and client.server_capabilities.inlayHintProvider
    if not inlayHintProvider then
      return
    end

    local enable = args.event == 'LspAttach'
    vim.lsp.inlay_hint.enable(enable, { bufnr = bufnr })
  end,
})

return M
