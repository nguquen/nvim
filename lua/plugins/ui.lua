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
        mode = 2, -- tab number + name; {N}gt goes to tab N
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
