-- darcula-solid + personal overrides:
-- comments, invisible characters, selection, diff colors

-- Load the base theme. Clear Lua's module cache so it re-applies on every :colorscheme.
package.loaded['darcula-solid'] = nil
require('darcula-solid')

vim.o.background = 'dark'
vim.g.colors_name = 'darcula-solid-ex'

local function set(name, val)
  vim.api.nvim_set_hl(0, name, val)
end

-- Same idea as lush.extends: keep the theme's attributes, override some of them
local function extend(name, val)
  local cur = vim.api.nvim_get_hl(0, { name = name, link = false })
  set(name, vim.tbl_extend('force', cur, val))
end

local special_grey = '#3b4048'

-- Comment
extend('Comment', { italic = false })

-- Invisible characters (listchars) --------------------------------------------
set('Whitespace', { fg = special_grey }) -- space, tab, trail, lead, nbsp
set('NonText', { fg = special_grey }) -- eol (line break), extends, precedes, showbreak

-- Selection --------------------------------------------------------------------
set('Visual', { bg = '#214283' }) -- no fg, so syntax colors stay visible

-- Diff mode (Diffview, :diffsplit, Fugitive) ----------------------------------
set('DiffAdd', { bg = '#294436' }) -- added lines
set('DiffChange', { bg = '#2B3644' }) -- changed line (subtle)
set('DiffText', { bg = '#3F5F82' }) -- changed characters (strong)
set('DiffDelete', { bg = '#4A2C2C' }) -- removed lines (Diffview copies this)
set('DiffviewDiffDeleteDim', { fg = special_grey }) -- ╱╱╱ filler lines

-- Git status colors (Diffview file panel) ---------------------
set('Added', { fg = '#8CA563' })
set('Changed', { fg = '#83B1F1' })
set('Removed', { fg = '#E74946' })
