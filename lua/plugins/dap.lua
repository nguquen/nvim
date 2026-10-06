-- [[ dap.lua ]] debuggers (Java's is in ftplugin/java.lua, Rust's comes with rustaceanvim)

local dap, dapui = require('dap'), require('dapui')
local mason_path = vim.fn.glob(vim.fn.stdpath('data') .. '/mason/')

-- javascript / typescript
dap.adapters['pwa-node'] = {
  type = 'server',
  host = 'localhost',
  port = '${port}',
  executable = {
    command = 'js-debug-adapter',
    args = { '${port}' },
  },
}

for _, language in ipairs({ 'typescript', 'javascript' }) do
  dap.configurations[language] = {
    {
      type = 'pwa-node',
      request = 'launch',
      name = 'Launch file',
      program = '${file}',
      cwd = '${workspaceFolder}',
    },
    {
      type = 'pwa-node',
      request = 'attach',
      name = 'Attach',
      processId = require('dap.utils').pick_process,
      cwd = '${workspaceFolder}',
    },
  }
end

-- go
require('dap-go').setup({})

-- python
require('dap-python').setup(mason_path .. '/packages/debugpy/venv/bin/python')

-- ui: opens when a session starts, closes when it ends
dapui.setup()

dap.listeners.after.event_initialized['dapui_config'] = function()
  dapui.open()
end

dap.listeners.before.event_terminated['dapui_config'] = function()
  dapui.close()
end

dap.listeners.before.event_exited['dapui_config'] = function()
  dapui.close()
end

require('nvim-dap-virtual-text').setup({})
