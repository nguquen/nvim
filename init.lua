-- [[ init.lua ]]

-- impatient for faster loading
require('impatient')

-- leader; works across all nvim files
vim.g.mapleader = " "

-- ensure the packer plugin manager is installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
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
  require("packer").sync()
  return
end

-- colorscheme
require('onedark').setup {
  style = 'dark',
  transparent = false,
  term_colors = true,
  code_style = {
    comments = 'none',
    keywords = 'none',
    functions = 'none',
    strings = 'none',
    variables = 'none'
  },
  colors = {
    special_grey = "#3b4048",
  },
  highlights = {
    Whitespace = { fg = '$special_grey' },
    NvimTreeNormal = { bg = '$bg0' },
    NvimTreeEndOfBuffer = { bg = '$bg0' },
  },
  lualine = {
    transparent = false,
  },
}
require('onedark').load()

-- devicons
require('nvim-web-devicons').setup {}

-- lualine
require('lualine').setup {
  options = {
    theme = 'onedark',
  }
}

-- nvim-tree
require("nvim-tree").setup({
  sort_by = "case_sensitive",
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
  },
})

-- telescope setup
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = "close",
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
      }
    }
  },
}

-- autopairs
require('nvim-autopairs').setup {}

-- gitsigns
require('gitsigns').setup {}

-- mason setup
require("mason").setup({
  ui = {
    icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗"
    }
  },
})

require("mason-lspconfig").setup {
  ensure_installed = { "rust_analyzer" },
}

require('mason-tool-installer').setup {
  ensure_installed = { "codelldb" },
}

-- rust
local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      -- hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
})

-- Completion Plugin Setup
local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local cmp = require'cmp'
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-j>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ["<Tab>"] = cmp.mapping(function(fallback)
      if vim.fn["vsnip#available"](1) == 1 then
        feedkey("<Plug>(vsnip-expand-or-jump)", "")
      elseif cmp.visible() then
        cmp.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = true,
        })
      elseif has_words_before() then
        cmp.complete()
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, { "i", "s" }),
    ['<C-S-f>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    }),
  },
  -- Installed sources:
  sources = {
    { name = 'path' },                              -- file paths
    { name = 'nvim_lsp', keyword_length = 2 },      -- from language server
    { name = 'nvim_lsp_signature_help'},            -- display function signatures with current parameter emphasized
    { name = 'nvim_lua', keyword_length = 2},       -- complete neovim's Lua runtime API such vim.lsp.*
    { name = 'buffer', keyword_length = 2 },        -- source current buffer
    { name = 'vsnip', keyword_length = 1 },         -- nvim-cmp source for vim-vsnip
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    fields = {'menu', 'abbr', 'kind'},
    format = function(entry, item)
      local menu_icon = {
        nvim_lsp = 'λ',
        vsnip = '⋗',
        buffer = 'b',
        path = 'p',
      }
      item.menu = menu_icon[entry.source.name]
      return item
    end,
  },
})

-- treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  sync_install = false,
  auto_install = true,
  ignore_install = {},
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  ident = { enable = true },
}

-- null-ls
-- require('null-ls').setup {}
