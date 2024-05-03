vim.opt.background = 'dark'
vim.g.colors_name = 'darcula-solid-ex'

local lush = require('lush')
local darcula_solid = require('lush_theme.darcula-solid')
local spec = lush.extends({ darcula_solid }).with(function()
  -- Pallete copied from https://github.com/briones-gabriel/darcula-solid.nvim/blob/main/lua/lush_theme/darcula-solid.lua
  local special_grey = lush.hsl('#3b4048')

  return {
    Comment({ darcula_solid.Comment, gui = 'none' }),
    Whitespace({ fg = special_grey }),
  }
end)

lush(spec)
