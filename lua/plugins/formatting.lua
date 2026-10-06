-- [[ formatting.lua ]] none-ls: formatters and linters that aren't language servers

local null_ls = require('null-ls')

null_ls.setup({
  on_attach = require('config.lsp').format_on_attach,
  sources = {
    null_ls.builtins.code_actions.refactoring,
    -- require('typescript.extensions.null-ls.code-actions'),
    -- require('none-ls.code_actions.eslint_d'),
    require('none-ls.formatting.trim_newlines'),
    require('none-ls.formatting.trim_whitespace'),
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettierd.with({
      extra_filetypes = { 'java' },
      disabled_filetypes = {
        'yaml',
        -- biome: start
        'astro',
        'css',
        'graphql',
        'html',
        'javascript',
        'javascriptreact',
        'json',
        'jsonc',
        'svelte',
        'typescript',
        'typescriptreact',
        'vue',
        -- biome: end
      },
    }),
    -- require('none-ls.formatting.eslint_d'),
    -- null_ls.builtins.formatting.black,
    -- null_ls.builtins.formatting.buf,
    -- require('none-ls.diagnostics.eslint_d'),
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
