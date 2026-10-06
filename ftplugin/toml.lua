if vim.fn.expand('%:t') ~= 'Cargo.toml' or vim.g.crates_setup_done then
  return
end
vim.g.crates_setup_done = true

-- attaches to this buffer and to every Cargo.toml opened later
require('crates').setup({
  lsp = {
    enabled = true,
    actions = true,
    completion = true,
    hover = true,
  },
})
