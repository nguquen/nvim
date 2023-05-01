local mason_path = vim.fn.glob(vim.fn.stdpath('data') .. '/mason/')
local jdtls_path = mason_path .. '/packages/jdtls'
local lombok_path = jdtls_path .. '/lombok.jar'

local config = {
  cmd = { 'jdtls', '--jvm-arg=-javaagent:' .. lombok_path },
  root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }),
  on_attach = function(_, _)
    require('jdtls.setup').add_commands()
  end,
}

require('jdtls').start_or_attach(config)
