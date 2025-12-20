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
    LspInlayHint({ darcula_solid.Comment, gui = 'none' }),
    MiniDiffSignAdd({ fg = lush.hsl('#629755'), bg = 'NONE' }),
    MiniDiffSignChange({ fg = lush.hsl('#689d6a'), bg = 'NONE' }),
    MiniDiffSignDelete({ fg = lush.hsl('#cc6666'), bg = 'NONE' }),
    MiniDiffOverAdd({ bg = lush.hsl('#2e4b2e') }),
    MiniDiffOverChange({ darcula_solid.Comment, bg = lush.hsl('#3a3a2a') }),
    MiniDiffOverChangeBuf({ darcula_solid.Comment, bg = lush.hsl('#3a3a2a') }),
    MiniDiffOverContext({ darcula_solid.Comment, bg = lush.hsl('#282828') }),
    MiniDiffOverContextBuf({ darcula_solid.Comment, bg = lush.hsl('#282828') }),
    MiniDiffOverDelete({ darcula_solid.Comment, bg = lush.hsl('#4b2e2e') }),
  }
end)

lush(spec)
