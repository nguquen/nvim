-- [[ lsp.lua ]]
-- Shared LSP setup. Per-server settings live in after/lsp/<server>.lua (after/, so they
-- override nvim-lspconfig's lsp/<server>.lua defaults). Buffer keymaps are in config/keymaps.lua.
local M = {}

require('lsp-format').setup({})

-- format on save through lsp-format; also used by none-ls
M.format_on_attach = function(client)
  require('lsp-format').on_attach(client)
end

vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- language servers (lspconfig names). enable: start with vim.lsp.enable(); plugins/mason.lua
-- installs every enabled one that's missing. format_on_save: attach lsp-format.
-- Java starts its own server with its own on_attach: see ftplugin/java.lua.
M.servers = {
  { name = 'biome', enable = true, format_on_save = true },
  { name = 'buf_ls', enable = true, format_on_save = true },
  { name = 'denols', enable = true, format_on_save = false },
  { name = 'efm', enable = true, format_on_save = true },
  { name = 'gopls', enable = true, format_on_save = true },
  { name = 'gradle_ls', enable = true, format_on_save = false },
  { name = 'helm_ls', enable = true, format_on_save = false },
  { name = 'jsonls', enable = true, format_on_save = false },
  { name = 'lua_ls', enable = true, format_on_save = false }, -- stylua (none-ls) formats Lua
  { name = 'prismals', enable = true, format_on_save = true },
  { name = 'pyright', enable = true, format_on_save = false },
  { name = 'ruff', enable = true, format_on_save = true },
  -- started by rustaceanvim, using rust-analyzer from PATH (rustup)
  { name = 'rust-analyzer', enable = false, format_on_save = true },
  { name = 'sqlls', enable = true, format_on_save = false }, -- sqlfluff (none-ls) formats SQL
  { name = 'taplo', enable = true, format_on_save = true },
  { name = 'ts_ls', enable = true, format_on_save = false }, -- consider https://github.com/pmizio/typescript-tools.nvim
  { name = 'yamlls', enable = true, format_on_save = true },
}

for _, server in ipairs(M.servers) do
  if server.format_on_save then
    vim.lsp.config(server.name, { on_attach = M.format_on_attach })
  end
  if server.enable then
    vim.lsp.enable(server.name)
  end
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
