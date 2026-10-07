-- [[ git.lua ]] gitsigns, git-blame, GitHub PRs and diffs

require('gitsigns').setup({
  sign_priority = 6,
})

vim.g.gitblame_enabled = 0
vim.g.gitblame_delay = 250

require('octo').setup({
  picker = 'telescope', -- "fzf-lua" | "snacks" | "default"
  enable_builtin = true, -- bare :Octo opens a command picker
  default_merge_method = 'squash',
  use_local_fs = true, -- right side of a review is the real file (LSP, gitsigns); asks to check out the PR branch
})

-- set while :PRDiff has moved gitsigns' base to the PR's merge base
local pr_base_set = false

require('diffview').setup({
  enhanced_diff_hl = true,
  view = {
    default = { winbar_info = true },
    file_history = { winbar_info = true },
  },
  hooks = {
    view_closed = function()
      if pr_base_set then
        pr_base_set = false
        require('gitsigns').change_base(nil, true)
      end
    end,
  },
})
vim.opt.fillchars:append({ diff = '╱' })
-- 0.12's default already has indent-heuristic, linematch:40 and inline:char
vim.opt.diffopt:remove({ 'linematch:40', 'inline:char' })
vim.opt.diffopt:append({ 'algorithm:histogram', 'linematch:60', 'inline:word' })

-- Diffview of the current PR against its base. While it's open, gitsigns also diffs every buffer
-- against the PR's merge base, so ]c / [c and :Gitsigns setqflist all walk the PR's changes.
vim.api.nvim_create_user_command('PRDiff', function()
  vim.system({ 'gh', 'pr', 'view', '--json', 'baseRefName', '-q', '.baseRefName' }, { text = true }, function(pr)
    local base = vim.trim(pr.stdout or '')
    if pr.code ~= 0 or base == '' then
      vim.schedule(function()
        vim.notify('No PR found for the current branch', vim.log.levels.ERROR)
      end)
      return
    end
    vim.system({ 'git', 'fetch', 'origin', base }, {}, function()
      vim.system({ 'git', 'merge-base', 'origin/' .. base, 'HEAD' }, { text = true }, function(mb)
        vim.schedule(function()
          vim.cmd('DiffviewOpen origin/' .. base .. '...HEAD --imply-local')
          if mb.code == 0 then
            pr_base_set = true
            require('gitsigns').change_base(vim.trim(mb.stdout), true)
          end
        end)
      end)
    end)
  end)
end, { desc = 'Diffview of current PR against its base' })
