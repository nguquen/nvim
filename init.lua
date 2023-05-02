-- [[ init.lua ]]

-- impatient for faster loading
require('impatient')

-- leader; works across all nvim files
vim.g.mapleader = ' '

-- ensure the packer plugin manager is installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- imports
require('vars') -- variables
require('opts') -- options
require('keys') -- keymaps
require('plug') -- plugins

-- the first run will install packer and our plugins
if packer_bootstrap then
  require('packer').sync()
  return
end

-- colorscheme
require('onedark').setup({
  style = 'dark',
  transparent = false,
  term_colors = true,
  code_style = {
    comments = 'none',
    keywords = 'none',
    functions = 'none',
    strings = 'none',
    variables = 'none',
  },
  colors = {
    special_grey = '#3b4048',
  },
  highlights = {
    Whitespace = { fg = '$special_grey' },
    NvimTreeNormal = { bg = '$bg0' },
    NvimTreeEndOfBuffer = { bg = '$bg0' },
    debugPC = { fg = '$fg', bg = '$bg1' },
  },
  lualine = {
    transparent = false,
  },
})
require('onedark').load()

-- devicons
require('nvim-web-devicons').setup({})

-- lualine
require('lualine').setup({
  options = {
    theme = 'onedark',
  },
  sections = {
    lualine_c = {
      {
        'filename',
        path = 4,
      },
      'lsp_progress',
    },
  },
  extensions = { 'nvim-tree', 'nvim-dap-ui' },
})

-- nvim-tree
require('nvim-tree').setup({
  sort_by = 'case_sensitive',
  renderer = {
    group_empty = true,
    icons = {
      show = {
        git = true,
        file = true,
        folder = true,
        folder_arrow = true,
      },
    },
  },
  filters = {},
})

-- telescope setup
require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ['<esc>'] = 'close',
        ['<C-j>'] = 'move_selection_next',
        ['<C-k>'] = 'move_selection_previous',
      },
    },
    wrap_results = true,
  },
  pickers = {
    find_files = {
      theme = 'ivy',
      sorting_strategy = 'descending',
      layout_config = {
        prompt_position = 'bottom',
        preview_cutoff = 180,
      },
    },
    live_grep = {
      theme = 'ivy',
      sorting_strategy = 'descending',
      layout_config = {
        prompt_position = 'bottom',
        preview_cutoff = 180,
      },
    },
    grep_string = {
      theme = 'ivy',
      sorting_strategy = 'descending',
      layout_config = {
        prompt_position = 'bottom',
        preview_cutoff = 180,
      },
    },
    buffers = {
      theme = 'ivy',
      sorting_strategy = 'descending',
      layout_config = {
        prompt_position = 'bottom',
        preview_cutoff = 180,
      },
    },
    keymaps = {
      theme = 'ivy',
      sorting_strategy = 'descending',
      layout_config = {
        prompt_position = 'bottom',
        preview_cutoff = 180,
      },
    },
    lsp_document_symbols = {
      theme = 'ivy',
      sorting_strategy = 'descending',
      layout_config = {
        prompt_position = 'bottom',
        preview_cutoff = 180,
      },
    },
    diagnostics = {
      theme = 'ivy',
      sorting_strategy = 'descending',
      -- path_display = 'hidden',
      layout_config = {
        prompt_position = 'bottom',
        preview_cutoff = 180,
      },
    },
    loclist = {
      theme = 'ivy',
      sorting_strategy = 'descending',
      layout_config = {
        prompt_position = 'bottom',
        preview_cutoff = 180,
      },
    },
    quickfix = {
      theme = 'ivy',
      sorting_strategy = 'descending',
      layout_config = {
        prompt_position = 'bottom',
        preview_cutoff = 180,
      },
    },
  },
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_cursor({}),
    },
    ['zf-native'] = {
      -- options for sorting file-like items
      file = {
        -- override default telescope file sorter
        enable = true,

        -- highlight matching text in results
        highlight_results = true,

        -- enable zf filename match priority
        match_filename = true,
      },

      -- options for sorting all other items
      generic = {
        -- override default telescope generic item sorter
        enable = true,

        -- highlight matching text in results
        highlight_results = true,

        -- disable zf filename match priority
        match_filename = false,
      },
    },
  },
})

require('telescope').load_extension('ui-select')
require('telescope').load_extension('zf-native')
require('telescope').load_extension('dap')

-- autopairs
require('nvim-autopairs').setup({})

-- gitsigns
require('gitsigns').setup({})

-- mason setup
require('mason').setup({
  ui = {
    icons = {
      package_installed = '✓',
      package_pending = '➜',
      package_uninstalled = '✗',
    },
  },
})

require('mason-lspconfig').setup({
  ensure_installed = {
    'rust_analyzer',
    'lua_ls',
    'tsserver',
    'jdtls',
    'gradle_ls',
    'gopls',
    'pyright',
    'yamlls',
  },
})

require('mason-tool-installer').setup({
  ensure_installed = {
    'codelldb',
    'stylua',
    'prettierd',
    'eslint_d',
    'java-debug-adapter',
    'java-test',
    'flake8',
    'black',
    'debugpy',
    'delve',
    'js-debug-adapter',
  },
})

local mason_path = vim.fn.glob(vim.fn.stdpath('data') .. '/mason/')
local this_os = vim.loop.os_uname().sysname

-- lsp-format
require('lsp-format').setup({})

local on_attach_lsp_format = function(client)
  require('lsp-format').on_attach(client)
end

-- Setup language servers
require('lspconfig').lua_ls.setup({
  -- on_attach = on_attach_lsp_format,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file('', true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
})

-- rust
local rt = require('rust-tools')
local codelldb_path = mason_path .. '/packages/codelldb/extension/adapter/codelldb'
local liblldb_path = mason_path .. '/packages/codelldb/extension/lldb/lib/liblldb'

liblldb_path = liblldb_path .. (this_os == 'Linux' and '.so' or '.dylib')

rt.setup({
  server = {
    on_attach = function(client, _)
      -- auto format
      on_attach_lsp_format(client)
    end,
    settings = {
      ['rust-analyzer'] = {
        check = {
          command = 'clippy',
        },
      },
    },
  },
  dap = {
    adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path),
  },
})

-- typescript
require('typescript').setup({
  disable_commands = false, -- prevent the plugin from creating Vim commands
  debug = false, -- enable debug logging for commands
  go_to_source_definition = {
    fallback = true, -- fall back to standard LSP definition on failure
  },
  server = { -- pass options to lspconfig's setup method
  },
})

require('dap').adapters['pwa-node'] = {
  type = 'server',
  host = 'localhost',
  port = '${port}',
  executable = {
    command = 'js-debug-adapter',
    args = { '${port}' },
  },
}

for _, language in ipairs({ 'typescript', 'javascript' }) do
  require('dap').configurations[language] = {
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

-- gradle
require('lspconfig').gradle_ls.setup({})

-- gopls
require('lspconfig').gopls.setup({
  on_attach = on_attach_lsp_format,
})
require('dap-go').setup({})

-- pyright
local debugpy_path = mason_path .. '/packages/debugpy/venv/bin/python'

require('lspconfig').pyright.setup({})
require('dap-python').setup(debugpy_path)

-- yamlls
require('lspconfig').yamlls.setup({
  settings = {
    yaml = {
      keyOrdering = false,
    },
  },
})

-- Completion Plugin Setup
local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local cmp = require('cmp')
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local lspkind = require('lspkind')

cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end,
  },
  mapping = {
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-j>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = false,
        })
      elseif vim.fn['vsnip#available'](1) == 1 then
        feedkey('<Plug>(vsnip-expand-or-jump)', '')
      elseif has_words_before() then
        cmp.complete()
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, { 'i', 's' }),
    ['<C-S-f>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = false,
    }),
  },
  -- Installed sources:
  sources = {
    { name = 'path' },
    { name = 'nvim_lsp', keyword_length = 2 },
    { name = 'nvim_lsp_signature_help' },
    { name = 'nvim_lua', keyword_length = 2 },
    { name = 'buffer', keyword_length = 2 },
    { name = 'vsnip', keyword_length = 1 },
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    fields = { 'abbr', 'kind', 'menu' },
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      preset = 'codicons',
      before = function(entry, vim_item)
        vim_item.menu = ({
          nvim_lsp = '[lsp]',
          nvim_lsp_signature_help = '[lsp signature]',
        })[entry.source.name] or ('[' .. entry.source.name:gsub('_', ' ') .. ']')
        return vim_item
      end,
    }),
  },
  enabled = function()
    return vim.api.nvim_buf_get_option(0, 'buftype') ~= 'prompt' or require('cmp_dap').is_dap_buffer()
  end,
})

require('cmp').setup.filetype({ 'dap-repl', 'dapui_watches', 'dapui_hover' }, {
  sources = {
    { name = 'dap' },
  },
})

cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

-- treesitter
require('nvim-treesitter.configs').setup({
  ensure_installed = 'all',
  sync_install = false,
  auto_install = true,
  ignore_install = {},
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  ident = { enable = true },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
})

-- todo
require('todo-comments').setup({})

-- comment
require('Comment').setup({
  toggler = {
    line = 'gcc',
    block = 'gbc',
  },
  opleader = {
    line = 'gc',
    block = 'gb',
  },
  mappings = {
    basic = true,
    extra = false,
  },
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
})

-- eyeliner
require('eyeliner').setup({
  highlight_on_key = true, -- show highlights only after keypress
  dim = true, -- dim all other characters if set to true (recommended!)
})

-- null-ls
local null_ls = require('null-ls')

null_ls.setup({
  on_attach = on_attach_lsp_format,
  sources = {
    null_ls.builtins.code_actions.refactoring,
    require('typescript.extensions.null-ls.code-actions'),
    null_ls.builtins.code_actions.eslint_d,
    null_ls.builtins.formatting.trim_newlines,
    null_ls.builtins.formatting.trim_whitespace,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.formatting.eslint_d,
    null_ls.builtins.formatting.black,
    null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.diagnostics.checkstyle.with({
      extra_args = { '-c', '/google_checks.xml' }, -- or "/sun_checks.xml" or path to self written rules
    }),
    null_ls.builtins.diagnostics.flake8,
  },
})

-- surround
require('nvim-surround').setup({})

-- colorizer
require('colorizer').setup()

-- dapui
local dap, dapui = require('dap'), require('dapui')

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
