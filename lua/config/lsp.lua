-- [[ lsp.lua ]]
-- Shared LSP setup. Per-server settings live in after/lsp/<server>.lua (after/, so they
-- override nvim-lspconfig's lsp/<server>.lua defaults). Buffer keymaps are in config/keymaps.lua.
local M = {}

require('lsp-format').setup({})

-- format on save through lsp-format; also used by none-ls and ftplugin/rust.lua
M.format_on_attach = function(client)
  require('lsp-format').on_attach(client)
end

vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- servers that format on save
for _, name in ipairs({ 'gopls', 'ruff', 'yamlls', 'efm', 'buf_ls', 'prismals', 'taplo', 'biome' }) do
  vim.lsp.config(name, { on_attach = M.format_on_attach })
end

-- servers to run; plugins/mason.lua installs each one that's missing.
-- Rust and Java start their own servers: see ftplugin/rust.lua and ftplugin/java.lua.
M.servers = {
  'biome',
  'buf_ls',
  'denols',
  'efm',
  'gopls',
  'gradle_ls',
  'helm_ls',
  'jsonls',
  'lua_ls',
  'prismals',
  'pyright',
  'ruff',
  'sqlls',
  'taplo',
  'ts_ls', -- consider https://github.com/pmizio/typescript-tools.nvim
  'yamlls',
}
vim.lsp.enable(M.servers)

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
