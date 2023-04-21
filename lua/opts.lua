-- [[ opts.lua ]]

-- with vim.opt we can set global, window and buffer settings, acting like :set in vimscript
local opt = vim.opt
local cmd = vim.api.nvim_command

-- [[ clipboard ]]
opt.clipboard = "unnamedplus"
opt.pastetoggle = "<F2>"

-- [[ editor ]]
opt.updatetime = 100
opt.number = true
opt.relativenumber = true
opt.visualbell = true
opt.listchars = "eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:·"
opt.list = true
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.splitbelow = true
opt.splitright = true
vim.api.nvim_create_autocmd("BufEnter", { callback = function() vim.opt.formatoptions = vim.opt.formatoptions - { "c","r","o" } end, })

-- [[ filetypes ]]
opt.encoding = 'utf8'
opt.fileencoding = 'utf8'

-- [[ theme ]]
opt.syntax = "ON"
opt.termguicolors = true

-- [[ completion ]]
opt.completeopt = {'menuone', 'noselect', 'noinsert'}
opt.shortmess = vim.opt.shortmess + { c = true}
vim.cmd([[
set signcolumn=yes
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

