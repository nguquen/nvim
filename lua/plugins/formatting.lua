-- [[ formatting.lua ]] none-ls: formatters and linters that aren't language servers

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
  on_attach = require('config.lsp').format_on_attach,
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
