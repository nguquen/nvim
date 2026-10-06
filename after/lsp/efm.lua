-- only used to format Helm templates
local helmfmt = {
  formatCommand = [[helmfmt --files ${INPUT} --stdout]],
  formatStdin = true,
}

return {
  filetypes = { 'helm' },
  init_options = { documentFormatting = true },
  settings = {
    languages = {
      helm = { helmfmt },
    },
  },
}
