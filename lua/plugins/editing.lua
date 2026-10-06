-- [[ editing.lua ]] pairs, comments, surround, motions, highlights

require('nvim-autopairs').setup({})

require('todo-comments').setup({})

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

require('eyeliner').setup({
  highlight_on_key = true, -- show highlights only after keypress
  dim = true, -- dim all other characters if set to true (recommended!)
})

require('nvim-surround').setup({})

require('colorizer').setup()
