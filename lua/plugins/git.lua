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

-- Runs cmd in the background; on_done gets its trimmed stdout, or nil if it failed or printed nothing
local function run(cmd, on_done)
  vim.system(cmd, { text = true }, function(r)
    local out = vim.trim(r.stdout or '')
    on_done(r.code == 0 and out ~= '' and out or nil)
  end)
end

-- on_found(branch, is_pr): the PR's base branch, or with no PR the remote's default branch
-- (origin/HEAD, else GitHub's), or nil
local function find_base(on_found)
  run({ 'gh', 'pr', 'view', '--json', 'baseRefName', '-q', '.baseRefName' }, function(pr_base)
    if pr_base then
      return on_found(pr_base, true)
    end
    run({ 'git', 'symbolic-ref', '--short', 'refs/remotes/origin/HEAD' }, function(head)
      if head then
        return on_found((head:gsub('^origin/', '')), false)
      end
      run({ 'gh', 'repo', 'view', '--json', 'defaultBranchRef', '-q', '.defaultBranchRef.name' }, function(default)
        on_found(default, false)
      end)
    end)
  end)
end

-- Diffview of the current branch against its PR's base (or the default branch before there is a PR).
-- While it's open, gitsigns also diffs every buffer against the merge base, so ]c / [c and
-- :Gitsigns setqflist all walk the branch's changes.
vim.api.nvim_create_user_command('PRDiff', function()
  find_base(function(base, is_pr)
    if not base then
      vim.schedule(function()
        vim.notify('PRDiff: no PR for this branch and no default branch found', vim.log.levels.ERROR)
      end)
      return
    end
    vim.system({ 'git', 'fetch', 'origin', base }, {}, function()
      run({ 'git', 'merge-base', 'origin/' .. base, 'HEAD' }, function(merge_base)
        vim.schedule(function()
          if not is_pr then
            vim.notify('PRDiff: no PR for this branch; diffing against origin/' .. base)
          end
          vim.cmd('DiffviewOpen origin/' .. base .. '...HEAD --imply-local')
          if merge_base then
            pr_base_set = true
            require('gitsigns').change_base(merge_base, true)
          end
        end)
      end)
    end)
  end)
end, { desc = 'Diffview of the current branch against its PR base or the default branch' })
