if vim.g.helm_ls_setup_done then
  return
end
vim.g.helm_ls_setup_done = true

-- the autocmds it creates cover every helm buffer, so set it up once
require('helm-ls').setup({
  conceal_templates = {
    enabled = false,
  },
  indent_hints = {
    enabled = true,
    only_for_current_line = true,
  },
  action_highlight = {
    enabled = true,
  },
})
