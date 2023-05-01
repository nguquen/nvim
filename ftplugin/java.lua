local mason_path = vim.fn.glob(vim.fn.stdpath('data') .. '/mason/')
local jdtls_path = mason_path .. '/packages/jdtls'
local lombok_path = jdtls_path .. '/lombok.jar'

local config = {
  cmd = { 'jdtls', '--jvm-arg=-javaagent:' .. lombok_path },
  root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }),
  on_attach = function(client, _)
    require('jdtls.setup').add_commands()
    require('lsp-format').on_attach(client)
  end,
  settings = {
    java = {
      format = {
        settings = {
          url = 'https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml',
          profile = 'GoogleStyle',
        },
      },
    },
  },
}

require('jdtls').start_or_attach(config)
