-- [[ ui.lua ]] colorscheme, icons, statusline, markdown rendering

vim.cmd.colorscheme('darcula-solid-ex')

require('nvim-web-devicons').setup({})

require('lualine').setup({
  options = {
    theme = 'auto',
    refresh = {
      statusline = 100,
      tabline = 100,
      winbar = 100,
    },
    always_show_tabline = false, -- tabline only with 2+ tabs, like Neovim's default
  },
  tabline = {
    lualine_a = {
      {
        'tabs',
        -- like Neovim's default label, but the tab number instead of the window count: `3+ ~/P/g/o/file.lua`
        -- (+ = a buffer in the tab is modified); {N}gt goes to tab N
        mode = 2,
        path = 1,
        tab_max_length = 0, -- lualine's own shortening runs before fmt and would mangle plugin buffer names
        -- flat tabs like the default tabline: no arrow separators between tabs or after the last one
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        separator = { left = '', right = '' },
        fmt = function(name)
          -- plugin buffers (diffview://, octo://): just the last part, e.g. DiffviewFilePanel or the file name
          if name:match('^%a[%w+.-]*://') then
            return vim.fn.fnamemodify(name, ':t')
          end
          return vim.fn.pathshorten(name)
        end,
        symbols = { modified = '+' },
        -- Neovim's default tabline colours; the auto theme gives active and inactive tabs the same colours
        tabs_color = { active = 'TabLineSel', inactive = 'TabLine' },
        max_length = function()
          return vim.o.columns
        end,
      },
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
