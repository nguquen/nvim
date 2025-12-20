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
-- require('onedark').setup({
--   style = 'dark',
--   transparent = false,
--   term_colors = true,
--   code_style = {
--     comments = 'none',
--     keywords = 'none',
--     functions = 'none',
--     strings = 'none',
--     variables = 'none',
--   },
--   colors = {
--     special_grey = '#3b4048',
--   },
--   highlights = {
--     Whitespace = { fg = '$special_grey' },
--     NvimTreeNormal = { bg = '$bg0' },
--     NvimTreeEndOfBuffer = { bg = '$bg0' },
--     debugPC = { fg = '$fg', bg = '$bg1' },
--   },
--   lualine = {
--     transparent = false,
--   },
-- })
-- require('onedark').load()

vim.cmd('colorscheme darcula-solid-ex')

-- devicons
require('nvim-web-devicons').setup({})

-- lualine
require('lualine').setup({
  options = {
    theme = 'auto',
    refresh = {
      statusline = 100,
      tabline = 100,
      winbar = 100,
    },
  },
  sections = {
    lualine_c = {
      {
        'filename',
        path = 3,
      },
      'lsp_progress',
    },
    lualine_x = {
      'encoding',
      'fileformat',
      'filetype',
      require('minuet.lualine'),
      require('plugins/codecompanion/lualine'),
      'copilot',
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
  filters = {
    dotfiles = false,
    git_ignored = false,
  },
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
    file_ignore_patterns = {
      '%.git/',
    },
  },
  pickers = {
    find_files = {
      theme = 'ivy',
      sorting_strategy = 'descending',
      hidden = true,
      no_ignore = false,
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

-- markdown
require('render-markdown').setup({
  file_types = { 'markdown', 'codecompanion' },
})

-- autopairs
require('nvim-autopairs').setup({})

-- gitsigns
require('gitsigns').setup({})

-- mini.diff
require('mini.diff').setup()

-- inlay-hint
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
  automatic_enable = false,
  ensure_installed = {
    'rust_analyzer',
    'lua_ls',
    'ts_ls',
    'jdtls',
    'gradle_ls',
    'gopls',
    'pyright',
    'yamlls',
    'buf_ls',
    'prismals',
    'denols',
    'sqlls',
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
    'taplo',
    'sqlfluff',
  },
})

local mason_path = vim.fn.glob(vim.fn.stdpath('data') .. '/mason/')

-- ai
require('copilot').setup({
  copilot_model = '',
  suggestion = { enabled = false },
  panel = { enabled = false },
  nes = { enabled = false },
  filetypes = {
    yaml = true,
    markdown = true,
    codecompanion = true,
    gitcommit = true,
    gitrebase = true,
    sh = function()
      if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
        -- disable for .env files
        return false
      end
      return true
    end,
  },
})

require('vectorcode').setup({
  n_query = 1,
  timeout_ms = 15000,
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'codecompanion' },
  callback = function()
    if not vim.b.copilot_attached then
      vim.api.nvim_command('Copilot! attach')
      vim.b.copilot_attached = true
    end
  end,
})

require('copilot_cmp').setup()

require('mcphub').setup({
  port = 3333,
  config = vim.fn.expand(vim.fn.stdpath('config') .. '/mcpservers.json'),
  auto_approve = true,
})

require('minuet').setup({
  provider = 'openai_fim_compatible',
  n_completions = 3,
  context_window = 16000,
  provider_options = {
    openai_fim_compatible = {
      api_key = 'TERM',
      name = 'Ollama',
      end_point = 'http://localhost:11434/v1/completions',
      model = 'qwen2.5-coder:14b-base-q4_K_M',
      optional = {
        max_tokens = 512,
        top_p = 0.9,
      },
    },
  },
  request_timeout = 10,
  cmp = {
    enable_auto_complete = true,
  },
})

require('codecompanion').setup({
  interactions = {
    chat = {
      adapter = 'copilot',
      -- adapter = 'ollama',
      tools = {
        opts = {
          auto_submit_success = true,
          auto_submit_errors = true,
        },
      },
      roles = {
        llm = function(adapter)
          return string.format(
            '  %s%s',
            adapter.formatted_name,
            adapter.parameters.model and ' (' .. adapter.parameters.model .. ')' or ''
          )
        end,
        user = '  ' .. vim.env.USER:gsub('^%l', string.upper),
      },
    },
    inline = {
      adapter = 'copilot',
      -- adapter = 'ollama',
    },
    cmd = {
      adapter = 'copilot',
      -- adapter = 'ollama',
    },
    background = {
      adapter = 'copilot',
      -- adapter = 'ollama',
    },
  },
  adapters = {
    acp = {
      claude_code = function()
        return require('codecompanion.adapters').extend('claude_code', {
          env = {},
        })
      end,
    },
    http = {
      ollama = function()
        return require('codecompanion.adapters').extend('ollama', {
          name = 'ollama',
          formatted_name = 'Ollama',
          env = {
            url = 'http://127.0.0.1:11434',
          },
          headers = {
            ['Content-Type'] = 'application/json',
          },
          schema = {
            model = {
              -- default = 'deepseek-r1:14b-qwen-distill-q4_K_M',
              default = 'qwen2.5-coder:14b-instruct-q4_K_M',
            },
          },
          handlers = {
            chat_output = function(self, data)
              local output = {}

              if data and data ~= '' then
                if not self.opts.stream then
                  data = data.body
                end
                local ok, json = pcall(vim.json.decode, data, { luanil = { object = true } })

                if not ok then
                  return { status = 'error' }
                end

                local message = json.message

                if message.content then
                  if message.content:sub(1, 7) == '<think>' then
                    output.content = '### Reasoning\n' .. message.content:sub(8)
                  elseif message.content:sub(-8) == '</think>' then
                    output.content = message.content:sub(1, -9) .. '\n### Response'
                  else
                    output.content = message.content
                  end
                  output.role = message.role or nil
                end

                return {
                  status = 'success',
                  output = output,
                }
              end

              return nil
            end,
          },
        })
      end,
      copilot = function()
        return require('codecompanion.adapters').extend('copilot', {
          schema = {
            model = {
              default = 'claude-haiku-4.5',
            },
          },
        })
      end,
    },
  },
  display = {
    chat = {
      intro_message = 'Welcome to CodeCompanion ✨! Press ? for options',
      show_header_separator = false,
      separator = '─',
      show_references = true,
      show_settings = false,
      show_token_count = true,
      start_in_insert_mode = false,
    },
  },
  prompt_library = {
    ['Unit Tests'] = {
      strategy = 'chat',
    },
  },
  opts = {
    -- send_code = false,
  },
  extensions = {
    spinner = {},
    mcphub = {
      callback = 'mcphub.extensions.codecompanion',
      opts = {
        make_vars = true,
        make_slash_commands = true,
        show_result_in_chat = false,
      },
    },
    -- vectorcode = {
    --   opts = {
    --     add_tool = true,
    --     add_slash_command = true,
    --     tool_opts = {
    --       default_num = 5,
    --     },
    --   },
    -- },
  },
})

-- lsp-format
require('lsp-format').setup({})

local on_attach_lsp_format = function(client)
  require('lsp-format').on_attach(client)
end

-- cmp-nvim-lsp capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup language servers
vim.lsp.config('lua_ls', {
  -- on_attach = on_attach_lsp_format,
  capabilities = capabilities,
  settings = {
    Lua = {
      hint = { enable = true },
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
vim.lsp.enable({ 'lua_ls' })

-- rust
vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {},
  -- LSP configuration
  server = {
    capabilities = capabilities,
    on_attach = function(client)
      -- auto format
      on_attach_lsp_format(client)
    end,
    default_settings = {
      -- rust-analyzer language server configuration
      ['rust-analyzer'] = {
        imports = {
          granularity = {
            group = 'module',
          },
          prefix = 'crate',
        },
        cargo = {
          buildScripts = {
            enable = true,
          },
        },
        procMacro = {
          enable = true,
          attributes = {
            enable = true,
          },
          ignored = {
            ['async-trait'] = { 'async_trait' },
          },
        },
        diagnostics = {
          enable = true,
          -- disabled = { 'macro-error', 'proc-macro-disabled' },
          disabled = { 'proc-macro-disabled' },
          experimental = {
            enable = false,
          },
        },
      },
    },
  },
  -- DAP configuration
  dap = {},
}

-- typescript
-- consider https://github.com/pmizio/typescript-tools.nvim
vim.lsp.enable({ 'ts_ls' })

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

-- deno
vim.lsp.config('denols', {
  root_dir = require('lspconfig.util').root_pattern('deno.json', 'deno.jsonc'),
})
vim.lsp.enable({ 'denols' })

-- gradle
vim.lsp.enable({ 'gradle_ls' })

-- gopls
vim.lsp.config('gopls', {
  on_attach = on_attach_lsp_format,
})
vim.lsp.enable({ 'gopls' })
require('dap-go').setup({})

-- pyright
local debugpy_path = mason_path .. '/packages/debugpy/venv/bin/python'

vim.lsp.enable({ 'pyright' })
require('dap-python').setup(debugpy_path)

-- yamlls
-- set YAML syntax for *.yaml.gotmpl
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.yaml.gotmpl',
  command = 'set filetype=yaml',
})

vim.lsp.config('yamlls', {
  settings = {
    yaml = {
      keyOrdering = false,
    },
  },
})
vim.lsp.enable({ 'yamlls' })

-- bufls
vim.lsp.config('buf_ls', {
  root_dir = require('lspconfig.util').root_pattern('buf.work.yaml', '.git'),
})
vim.lsp.enable({ 'buf_ls' })

-- prismals
vim.lsp.config('prismals', {
  on_attach = on_attach_lsp_format,
})
vim.lsp.enable({ 'prismals' })

-- sqlls
vim.lsp.enable({ 'sqlls' })

-- taplo
vim.lsp.config('taplo', {
  on_attach = on_attach_lsp_format,
})
vim.lsp.enable({ 'taplo' })

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
  preselect = cmp.PreselectMode.None,
  completion = {
    completeopt = 'menu,menuone,noinsert',
    autocomplete = {
      cmp.TriggerEvent.TextChanged,
      cmp.TriggerEvent.InsertEnter,
    },
  },
  experimental = {
    ghost_text = false,
  },
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
      if cmp.core.view:visible() then
        local entry = cmp.get_selected_entry()
        if not entry then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        end
        cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false })
      elseif vim.fn['vsnip#available'](1) == 1 then
        feedkey('<Plug>(vsnip-expand-or-jump)', '')
      elseif has_words_before() then
        cmp.complete({})
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, { 'i', 's' }),
    ['<C-S-f>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping({
      i = function(fallback)
        if cmp.core.view:visible() and cmp.core.view:get_active_entry() then
          cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false })
        else
          fallback()
        end
      end,
      s = cmp.mapping.confirm({ select = true }),
    }),
    ['<M-y>'] = require('minuet').make_cmp_map(),
  },
  -- Installed sources:
  sources = {
    { name = 'copilot', priority = 100 },
    -- { name = 'minuet', priority = 100 },
    { name = 'path' },
    { name = 'nvim_lsp', priority = 100 },
    { name = 'nvim_lsp_signature_help' },
    { name = 'nvim_lua' },
    { name = 'crates' },
    { name = 'vsnip' },
    {
      name = 'buffer',
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end,
      },
    },
    { name = 'vim-dadbod-completion', priority = 100 },
    { name = 'render-markdown' },
  },
  performance = {
    fetching_timeout = 10000,
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
      symbol_map = {
        Copilot = '',
        Ollama = '󰳆',
      },
      before = function(entry, vim_item)
        vim_item.menu = ({
          nvim_lsp = '[lsp]',
          nvim_lsp_signature_help = '[lsp signature]',
          ['vim-dadbod-completion'] = '[DB]',
        })[entry.source.name] or ('[' .. entry.source.name:gsub('_', ' ') .. ']')
        return vim_item
      end,
    }),
  },
  sorting = {
    priority_weight = 2,
    comparators = {
      require('copilot_cmp.comparators').prioritize,
      require('copilot_cmp.comparators').score,

      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.locality,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
      cmp.config.compare.kind,
    },
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
  ensure_installed = { 'lua', 'rust', 'javascript', 'typescript' },
  sync_install = false,
  auto_install = true,
  ignore_install = {},
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  ident = { enable = true },
})

-- todo
require('todo-comments').setup({})

-- comment
require('ts_context_commentstring').setup({
  enable_autocmd = false,
})

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
    -- require('typescript.extensions.null-ls.code-actions'),
    require('none-ls.code_actions.eslint_d'),
    require('none-ls.formatting.trim_newlines'),
    require('none-ls.formatting.trim_whitespace'),
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettierd,
    require('none-ls.formatting.eslint_d'),
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.buf,
    require('none-ls.diagnostics.eslint_d'),
    null_ls.builtins.diagnostics.checkstyle.with({
      extra_args = { '-c', '/google_checks.xml' }, -- or "/sun_checks.xml" or path to self written rules
    }),
    require('none-ls.diagnostics.flake8'),
    null_ls.builtins.diagnostics.buf,
    -- null_ls.builtins.formatting.taplo,
    null_ls.builtins.formatting.sqlfluff.with({
      extra_args = { '--dialect', 'postgres' }, -- change to your dialect
    }),
  },
  temp_dir = '/tmp',
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

-- gitblame
vim.g.gitblame_enabled = 0
vim.g.gitblame_delay = 250

-- crates
require('crates').setup({
  lsp = {
    enabled = true,
    actions = true,
    completion = true,
    hover = true,
  },
})

-- dadbod
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_win_position = 'right'
vim.g.db_ui_save_location = './queries'
