-- [[ lsp.lua ]]
-- Shared LSP setup, plus none-ls (formatters, linters and code actions that aren't language
-- servers). Per-server settings live in after/lsp/<server>.lua (after/, so they override
-- nvim-lspconfig's lsp/<server>.lua defaults). Buffer keymaps are in config/keymaps.lua.
local M = {}

require('lsp-format').setup({})

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
  -- none-ls, set up below; its tools are in plugins/mason.lua
  { name = 'null-ls', enable = false, install = false, format_on_save = true },
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

-- an autocmd rather than on_attach, so it also covers clients started by nvim-jdtls,
-- rustaceanvim and none-ls
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and format_on_save[client.name] then
      require('lsp-format').on_attach(client, args.buf)
    end
  end,
})

-- [[ none-ls ]]
local null_ls = require('null-ls')

-- eslint_d only runs in projects with an eslint config (eslint.config.*, .eslintrc*, or
-- "eslintConfig" in package.json); elsewhere it would error on every JS/TS file
local has_eslint_config = require('null-ls.helpers').cache.by_bufnr(function(params)
  return require('null-ls.utils').cosmiconfig('eslint', 'eslintConfig')(params.bufname) ~= nil
end)
local function eslint_d(source)
  return require('none-ls.' .. source .. '.eslint_d').with({ runtime_condition = has_eslint_config })
end

null_ls.setup({
  sources = {
    -- require('typescript.extensions.null-ls.code-actions'),
    eslint_d('code_actions'),
    eslint_d('diagnostics'),
    require('none-ls.formatting.trim_newlines'),
    require('none-ls.formatting.trim_whitespace'),
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettierd.with({
      extra_filetypes = { 'java' },
      disabled_filetypes = { 'yaml' },
      -- in projects with a biome.json, biome formats instead
      runtime_condition = function(params)
        return #vim.lsp.get_clients({ bufnr = params.bufnr, name = 'biome' }) == 0
      end,
    }),
    -- after prettierd, so eslint --fix gets the last word
    eslint_d('formatting'),
    -- null_ls.builtins.formatting.black,
    -- null_ls.builtins.formatting.buf,
    -- only for projects with their own checkstyle.xml, and only when checkstyle is installed
    null_ls.builtins.diagnostics.checkstyle.with({
      extra_args = { '-c', '$ROOT/checkstyle.xml' }, -- or "/google_checks.xml" or "/sun_checks.xml" or path to self written rules
      condition = function(utils)
        return vim.fn.executable('checkstyle') == 1 and utils.root_has_file({ 'checkstyle.xml' })
      end,
    }),
    -- null_ls.builtins.formatting.google_java_format,
    -- require('none-ls.diagnostics.flake8'),
    -- null_ls.builtins.diagnostics.buf,
    -- null_ls.builtins.formatting.taplo,
    null_ls.builtins.formatting.sqlfluff.with({
      extra_args = { '--dialect', 'postgres' }, -- change to your dialect
    }),
    null_ls.builtins.formatting.npm_groovy_lint.with({
      filetypes = { 'groovy' },
    }),
  },
  temp_dir = '/tmp',
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
