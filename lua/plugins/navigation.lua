-- [[ navigation.lua ]] file tree and telescope

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

-- every picker uses the same bottom-prompt ivy layout
local ivy = function(extra)
  return vim.tbl_extend('force', {
    theme = 'ivy',
    sorting_strategy = 'descending',
    layout_config = {
      prompt_position = 'bottom',
      preview_cutoff = 180,
    },
  }, extra or {})
end

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
    find_files = ivy({ hidden = true, no_ignore = false }),
    live_grep = ivy(),
    grep_string = ivy(),
    buffers = ivy(),
    keymaps = ivy(),
    lsp_document_symbols = ivy(),
    diagnostics = ivy(),
    loclist = ivy(),
    quickfix = ivy(),
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
