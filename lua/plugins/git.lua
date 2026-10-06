-- [[ git.lua ]] gitsigns, git-blame, GitHub PRs and diffs

require('gitsigns').setup({
  sign_priority = 6,
})

vim.g.gitblame_enabled = 0
vim.g.gitblame_delay = 250

require('octo').setup({
  picker = 'telescope', -- "fzf-lua" | "snacks" | "default"
  enable_builtin = true, -- bare :Octo opens a command picker
})

require('diffview').setup({ enhanced_diff_hl = true })
vim.opt.fillchars:append({ diff = '╱' })
vim.opt.diffopt:append({ 'algorithm:histogram', 'indent-heuristic', 'linematch:60' })

vim.api.nvim_create_user_command('PRDiff', function()
  local base = vim.fn.trim(vim.fn.system({
    'gh',
    'pr',
    'view',
    '--json',
    'baseRefName',
    '-q',
    '.baseRefName',
  }))
  if vim.v.shell_error ~= 0 or base == '' then
    vim.notify('No PR found for the current branch', vim.log.levels.ERROR)
    return
  end
  vim.fn.system({ 'git', 'fetch', 'origin', base })
  vim.cmd('DiffviewOpen origin/' .. base .. '...HEAD --imply-local')
end, { desc = 'Diffview of current PR against its base' })
