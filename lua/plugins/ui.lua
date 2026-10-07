-- [[ ui.lua ]] colorscheme, icons, statusline, markdown rendering

vim.cmd.colorscheme('darcula-solid-ex')

require('nvim-web-devicons').setup({})

-- tabline items are flat like Neovim's default tabline (no arrow separators) and use its colours; the auto theme
-- gives active and inactive items the same colours
local flat = {
  section_separators = { left = '', right = '' },
  component_separators = { left = '', right = '' },
  separator = { left = '', right = '' },
}
local tabline_colors = { active = 'TabLineSel', inactive = 'TabLine' }
-- │ between two inactive buffers or tabs; none next to the current one, which stands out by its colour
local between_inactive = { left = '│', right = '│' }

require('lualine').setup({
  options = {
    theme = 'auto',
    refresh = {
      statusline = 100,
      tabline = 100,
      winbar = 100,
    },
  },
  tabline = {
    -- listed buffers: `4 git.lua+` (buffer number, so :b4 jumps; # = alternate file)
    lualine_a = {
      vim.tbl_extend('force', flat, {
        'buffers',
        component_separators = between_inactive,
        mode = 4,
        symbols = { modified = '+', alternate_file = '#', directory = '' },
        buffers_color = tabline_colors,
        max_length = function()
          return vim.o.columns * 2 / 3
        end,
      }),
    },
    -- tabs, only with 2+: like Neovim's default label, but the tab number instead of the window count:
    -- `3+ ~/P/g/o/file.lua` (+ = a buffer in the tab is modified); {N}gt goes to tab N
    lualine_z = {
      vim.tbl_extend('force', flat, {
        'tabs',
        component_separators = between_inactive,
        cond = function()
          return vim.fn.tabpagenr('$') > 1
        end,
        mode = 2,
        path = 1,
        tab_max_length = 0, -- lualine's own shortening runs before fmt and would mangle plugin buffer names
        fmt = function(name)
          -- plugin buffers (diffview://, octo://): just the last part, e.g. DiffviewFilePanel or the file name
          if name:match('^%a[%w+.-]*://') then
            return vim.fn.fnamemodify(name, ':t')
          end
          return vim.fn.pathshorten(name)
        end,
        symbols = { modified = '+' },
        tabs_color = tabline_colors,
        max_length = function()
          return vim.o.columns / 3
        end,
      }),
    },
  },
  sections = {
    lualine_c = {
      {
        'filename',
        path = 3,
      },
      -- attached language servers, with a spinner while one is busy
      'lsp_status',
    },
    lualine_x = {
      'encoding',
      'fileformat',
      'filetype',
    },
  },
  extensions = { 'nvim-tree', 'nvim-dap-ui' },
})

require('render-markdown').setup({
  file_types = { 'markdown' },
  -- needs a latex parser plus utftex or latex2text; no math rendering
  latex = { enabled = false },
})
