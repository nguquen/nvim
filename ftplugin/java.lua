local mason_path = vim.fn.stdpath('data') .. '/mason'
local jdtls_path = mason_path .. '/packages/jdtls'
local lombok_path = jdtls_path .. '/lombok.jar'
local java_debug_path = mason_path .. '/packages/java-debug-adapter'
local java_test_path = mason_path .. '/packages/java-test'

-- jdtls extensions for debugging and running tests; skipped until Mason installs them.
-- The java-test runner and jacoco agent jars aren't extensions (see nvim-jdtls README).
local not_bundles = {
  ['com.microsoft.java.test.runner-jar-with-dependencies.jar'] = true,
  ['jacocoagent.jar'] = true,
}
local bundles = vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar', true, true)
for _, jar in ipairs(vim.fn.glob(java_test_path .. '/extension/server/*.jar', true, true)) do
  if not not_bundles[vim.fs.basename(jar)] then
    table.insert(bundles, jar)
  end
end

local config = {
  cmd = { 'jdtls', '--jvm-arg=-javaagent:' .. lombok_path },
  root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }),
  init_options = {
    bundles = bundles,
  },
  -- format on save: see jdtls in config/lsp.lua's servers table
  on_attach = function()
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
  end,
  settings = {
    java = {
      format = {
        enabled = false, -- disable to use prettier-java
      },
    },
  },
}

require('jdtls').start_or_attach(config)
