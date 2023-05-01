local mason_path = vim.fn.glob(vim.fn.stdpath('data') .. '/mason/')
local jdtls_path = mason_path .. '/packages/jdtls'
local lombok_path = jdtls_path .. '/lombok.jar'
local java_debug_path = mason_path .. '/packages/java-debug-adapter'
local java_test_path = mason_path .. '/packages/java-test'

local bundles = {
  vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar', 1),
}

vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. '/extension/server/*.jar', 1), '\n'))

local config = {
  cmd = { 'jdtls', '--jvm-arg=-javaagent:' .. lombok_path },
  root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }),
  init_options = {
    bundles = bundles,
  },
  on_attach = function(client, _)
    require('jdtls').setup_dap({ hotcodereplace = 'auto' })
    require('dap').configurations.java = {
      {
        type = 'java',
        request = 'attach',
        name = 'Debug (Attach) - Remote',
        hostName = '127.0.0.1',
        port = 5005,
      },
    }
    require('lsp-format').on_attach(client)
    require('jdtls.setup').add_commands()
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
