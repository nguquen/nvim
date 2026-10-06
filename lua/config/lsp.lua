-- [[ lsp.lua ]]
-- Shared LSP setup. Per-server settings live in after/lsp/<server>.lua (after/, so they
-- override nvim-lspconfig's lsp/<server>.lua defaults). Buffer keymaps are in config/keymaps.lua.
local M = {}

require('lsp-format').setup({})

-- format on save through lsp-format; for servers, see format_on_save below. none-ls uses it directly.
M.format_on_attach = function(client, bufnr)
  require('lsp-format').on_attach(client, bufnr)
end

vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- language servers, by client name (lspconfig names for vim.lsp.enable and Mason).
-- enable: start with vim.lsp.enable(); false for servers a plugin starts itself.
-- install: plugins/mason.lua installs it if missing.
-- format_on_save: attach lsp-format when the client attaches, however it was started.
M.servers = {
  { name = 'biome', enable = true, install = true, format_on_save = true },
  { name = 'buf_ls', enable = true, install = true, format_on_save = true },
  { name = 'denols', enable = true, install = true, format_on_save = false },
  { name = 'efm', enable = true, install = true, format_on_save = true },
  { name = 'gopls', enable = true, install = true, format_on_save = true },
  { name = 'gradle_ls', enable = true, install = true, format_on_save = false },
  { name = 'helm_ls', enable = true, install = true, format_on_save = false },
  -- started by nvim-jdtls in ftplugin/java.lua
  { name = 'jdtls', enable = false, install = true, format_on_save = true },
  { name = 'jsonls', enable = true, install = true, format_on_save = false },
  { name = 'lua_ls', enable = true, install = true, format_on_save = false }, -- stylua (none-ls) formats Lua
  { name = 'prismals', enable = true, install = true, format_on_save = true },
  { name = 'pyright', enable = true, install = true, format_on_save = false },
  { name = 'ruff', enable = true, install = true, format_on_save = true },
  -- started by rustaceanvim, using rust-analyzer from PATH (rustup)
  { name = 'rust-analyzer', enable = false, install = false, format_on_save = true },
  { name = 'sqlls', enable = true, install = true, format_on_save = false }, -- sqlfluff (none-ls) formats SQL
  { name = 'taplo', enable = true, install = true, format_on_save = true },
  { name = 'ts_ls', enable = true, install = true, format_on_save = false }, -- consider typescript-tools.nvim
  { name = 'yamlls', enable = true, install = true, format_on_save = true },
}

local format_on_save = {}
for _, server in ipairs(M.servers) do
  format_on_save[server.name] = server.format_on_save
  if server.enable then
    vim.lsp.enable(server.name)
  end
end

-- an autocmd rather than on_attach, so it also covers clients started by nvim-jdtls and rustaceanvim
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and format_on_save[client.name] then
      M.format_on_attach(client, args.buf)
    end
  end,
})

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
