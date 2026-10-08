-- [[ git.lua ]] gitsigns, git-blame, GitHub PRs and diffs

require('gitsigns').setup({
  sign_priority = 6,
})

vim.g.gitblame_enabled = 0
vim.g.gitblame_delay = 250

-- Runs cmd in the background; on_done gets its trimmed stdout, or nil if it failed or printed nothing
local function run(cmd, on_done)
  vim.system(cmd, { text = true }, function(r)
    local out = vim.trim(r.stdout or '')
    on_done(r.code == 0 and out ~= '' and out or nil)
  end)
end

require('octo').setup({
  picker = 'telescope', -- "fzf-lua" | "snacks" | "default"
  enable_builtin = true, -- bare :Octo opens a command picker
  default_merge_method = 'squash',
  use_local_fs = true, -- right side of a review is the real file (LSP, gitsigns); asks to check out the PR branch
  mappings = {
    -- octo's default <leader>qa makes <leader>q (quit) wait timeoutlen in PR buffers; review keys live under <leader>r
    pull_request = { approve_pr = { lhs = '<leader>ra', desc = 'approve PR' } },
  },
})

-- Octo bug with use_local_fs: showing a file fires BufEnter on the right-side real file, octo's BufEnter autocmd
-- reloads the layout for it, which fires BufEnter again, and so on until Neovim's autocmd nesting limit
-- ("No matching autocommands: filetypedetect BufRead"). Skip the reload when that buffer already is the right side.
local octo = require('octo')
local update_layout_for_current_file = octo.update_layout_for_current_file
---@diagnostic disable-next-line: duplicate-set-field
octo.update_layout_for_current_file = function()
  local review = require('octo.reviews').get_current_review()
  local file = review and review.layout and review.layout:get_current_file()
  if file and file.right_bufid == vim.api.nvim_get_current_buf() then
    return
  end
  return update_layout_for_current_file()
end

-- Octo review windows get Diffview's colours (enhanced_diff_hl) instead of octo's own (left side all red, right side
-- all green): removed lines red, added green, changed lines DiffChange with DiffText / DiffTextAdd for the changed
-- text, filler ╱ dimmed. Octo sets its colours in per-window highlight namespaces each time a review opens.
local octo_constants = require('octo.constants')
local octo_review_hl = {
  [octo_constants.OCTO_REVIEW_LEFT_HIGHLIGHT_NS] = {
    DiffAdd = 'DiffviewDiffAddAsDelete',
    DiffDelete = 'DiffviewDiffDeleteDim',
    DiffChange = 'DiffviewDiffChange',
    DiffText = 'DiffviewDiffText',
  },
  [octo_constants.OCTO_REVIEW_RIGHT_HIGHLIGHT_NS] = {
    DiffAdd = 'DiffviewDiffAdd',
    DiffDelete = 'DiffviewDiffDeleteDim',
    DiffChange = 'DiffviewDiffChange',
    DiffText = 'DiffviewDiffText',
  },
}
local OctoLayout = require('octo.reviews.layout').Layout
local init_layout = OctoLayout.init_layout
---@diagnostic disable-next-line: duplicate-set-field
OctoLayout.init_layout = function(self)
  init_layout(self)
  for ns, groups in pairs(octo_review_hl) do
    for group, link in pairs(groups) do
      vim.api.nvim_set_hl(ns, group, { link = link })
    end
  end
end

-- Octo review's changed-files panel on the left, full height, like Diffview's (octo puts it at the bottom and has
-- no option for it). Same as octo's FilePanel:open otherwise.
local OctoFilePanel = require('octo.reviews.file-panel').FilePanel
---@diagnostic disable-next-line: duplicate-set-field
OctoFilePanel.open = function(self)
  if not self:buf_loaded() then
    self:init_buffer()
  end
  if self:is_open() then
    return
  end
  vim.cmd('topleft vsplit')
  vim.cmd('vertical resize 40')
  self.winid = vim.api.nvim_get_current_win()
  vim.cmd('buffer ' .. self.bufid)
  for k, v in pairs(OctoFilePanel.winopts) do
    vim.api.nvim_set_option_value(k, v, { win = self.winid, scope = 'local' })
  end
  vim.cmd('wincmd =')
end

-- Octo checks a PR out with `gh pr checkout <n>`, as a local branch named after the PR's head branch. While another
-- worktree has that branch (an agent's worktree, even one whose folder is gone) git refuses to check it out, and the
-- review's right side falls back to the read-only octo:// copy. Then check the PR out as pr-<n> instead, tracking
-- the PR branch (octo's in_pr_branch accepts any local name with that upstream); re-running it pulls new commits.

-- on_done(branch) with the PR's head branch if another worktree has it checked out, else on_done(nil); on_done
-- runs in a vim.system callback
local function pr_branch_in_other_worktree(pr_number, repo, on_done)
  local view = { 'gh', 'pr', 'view', tostring(pr_number), '--json', 'headRefName', '-q', '.headRefName' }
  if repo then
    vim.list_extend(view, { '--repo', repo })
  end
  run(view, function(head)
    if not head then
      return on_done(nil)
    end
    run({ 'git', 'branch', '--show-current' }, function(current)
      run({ 'git', 'worktree', 'list', '--porcelain' }, function(worktrees)
        local held = current ~= head
          and ('\n' .. (worktrees or '') .. '\n'):find('\nbranch refs/heads/' .. vim.pesc(head) .. '\n')
        on_done(held and head or nil)
      end)
    end)
  end)
end

local octo_utils = require('octo.utils')
local octo_gh = require('octo.gh')

-- the local branch for the PR when another worktree has its head branch (held); tells the user
local function pr_branch_name(pr_number, held)
  local branch = 'pr-' .. pr_number
  octo_utils.info(held .. ' is checked out in another worktree; checking the PR out as ' .. branch)
  return branch
end

-- from a PR buffer or the PR picker
local checkout_pr = octo_utils.checkout_pr
---@diagnostic disable-next-line: duplicate-set-field
octo_utils.checkout_pr = function(pr_number)
  pr_branch_in_other_worktree(pr_number, nil, function(held)
    vim.schedule(function()
      if not held then
        return checkout_pr(pr_number)
      end
      local branch = pr_branch_name(pr_number, held)
      octo_gh.pr.checkout({
        pr_number,
        branch = branch,
        opts = {
          cb = function(_, stderr, status)
            if status == 0 then
              octo_utils.info('Switched to ' .. branch)
            else
              octo_utils.error(stderr)
            end
          end,
        },
      })
    end)
  end)
end

-- from the prompt when a review starts outside the PR branch
local checkout_pr_sync = octo_utils.checkout_pr_sync
---@diagnostic disable-next-line: duplicate-set-field
octo_utils.checkout_pr_sync = function(opts)
  local held
  pr_branch_in_other_worktree(opts.pr_number, opts.repo, function(branch)
    held = branch or false
  end)
  vim.wait(require('octo.config').values.timeout, function()
    return held ~= nil
  end)
  if not held then
    return checkout_pr_sync(opts)
  end
  octo_gh.pr.checkout({
    opts.pr_number,
    repo = opts.repo,
    branch = pr_branch_name(opts.pr_number, held),
    opts = { mode = 'sync' },
  })
  octo_utils.info('Switched to ' .. vim.trim(vim.fn.system({ 'git', 'branch', '--show-current' })))
end

-- In a review tab (an Octo review, or Diffview opened by :PRDiff), gitsigns diffs the tab's real files against
-- the PR's merge base instead of HEAD, which is the PR head once it's checked out. Other tabs keep HEAD. The
-- base is per buffer, so a file shown in both kinds of tab follows the tab you're in.
-- Octo has no review events, so this uses octo internals: it marks review buffers with b:octo_diff_props.

-- tabpage -> merge base for the review tabs
local tab_base = {}

-- Gives buf the base of the tab it's shown in (nil = back to HEAD), once gitsigns has finished its first
-- update of the buffer; a change_base during gitsigns' attach is lost (User GitSignsUpdate retries).
local function apply_review_base(buf)
  local b = vim.b[buf]
  if (b.review_base_applied or false) == (b.review_base or false) or (b.gitsigns_status_dict or {}).added == nil then
    return
  end
  b.review_base_applied = b.review_base or false
  vim.api.nvim_buf_call(buf, function()
    require('gitsigns').change_base(b.review_base)
  end)
end

-- Sets the base of every buffer shown in the current tab to the tab's
local function sync_review_base()
  local base = tab_base[vim.api.nvim_get_current_tabpage()]
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    vim.b[buf].review_base = base
    apply_review_base(buf)
  end
end

local review_group = vim.api.nvim_create_augroup('ReviewGitsigns', { clear = true })
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = review_group,
  callback = function(ev)
    local props = vim.b[ev.buf].octo_diff_props
    if props and props.split == 'RIGHT' and not vim.api.nvim_buf_get_name(ev.buf):match('^octo://') then
      local review = require('octo.reviews').get_current_review()
      local base = review and review.pull_request.left.commit
      if base then
        tab_base[vim.api.nvim_get_current_tabpage()] = base
      end
    end
    sync_review_base()
  end,
})
vim.api.nvim_create_autocmd('TabEnter', { group = review_group, callback = sync_review_base })
vim.api.nvim_create_autocmd('User', {
  group = review_group,
  pattern = 'GitSignsUpdate',
  callback = function(ev)
    local buf = ev.data and ev.data.buffer
    if buf then
      apply_review_base(buf)
    end
  end,
})
vim.api.nvim_create_autocmd('TabClosed', {
  group = review_group,
  callback = function()
    for tab in pairs(tab_base) do
      if not vim.api.nvim_tabpage_is_valid(tab) then
        tab_base[tab] = nil
      end
    end
    -- buffers that are now hidden keep their base until they're shown again (BufWinEnter syncs them): gitsigns
    -- defers a hidden buffer's update to its next BufEnter, and a change_base racing that update is lost
    sync_review_base()
  end,
})

-- same file keys as an octo review: ]q / [q next / previous, [Q / ]Q first / last (<tab> / <s-tab> still work)
local diffview_actions = require('diffview.actions')
local diffview_file_keys = {
  { 'n', ']q', diffview_actions.select_next_entry, { desc = 'Open the diff for the next file' } },
  { 'n', '[q', diffview_actions.select_prev_entry, { desc = 'Open the diff for the previous file' } },
  { 'n', '[Q', diffview_actions.select_first_entry, { desc = 'Open the diff for the first file' } },
  { 'n', ']Q', diffview_actions.select_last_entry, { desc = 'Open the diff for the last file' } },
}

require('diffview').setup({
  enhanced_diff_hl = true,
  keymaps = {
    view = diffview_file_keys,
    file_panel = diffview_file_keys,
    file_history_panel = diffview_file_keys,
  },
  view = {
    default = { winbar_info = true },
    file_history = { winbar_info = true },
  },
})
vim.opt.fillchars:append({ diff = '╱' })
-- 0.12's default already has indent-heuristic, linematch:40 and inline:char
vim.opt.diffopt:remove({ 'linematch:40', 'inline:char' })
vim.opt.diffopt:append({ 'algorithm:histogram', 'linematch:60', 'inline:word' })

-- on_found(branch, pr_url): the PR's base branch and URL, or with no PR the remote's default branch
-- (origin/HEAD, else GitHub's) and nil, or nil
-- on_pr(base, url) with the base branch and URL of branch's PR (branch nil: the current branch's), or on_pr()
local function find_pr(branch, on_pr)
  local cmd = { 'gh', 'pr', 'view', '--json', 'baseRefName,url', '-q', '.baseRefName + " " + .url' }
  if branch then
    table.insert(cmd, 4, branch)
  end
  run(cmd, function(pr)
    on_pr((pr or ''):match('^(%S+) (%S+)$'))
  end)
end

-- on_found(branch) with origin/HEAD's branch, else GitHub's default branch, or nil
local function find_default_branch(on_found)
  run({ 'git', 'symbolic-ref', '--short', 'refs/remotes/origin/HEAD' }, function(head)
    if head then
      return on_found((head:gsub('^origin/', '')))
    end
    run({ 'gh', 'repo', 'view', '--json', 'defaultBranchRef', '-q', '.defaultBranchRef.name' }, on_found)
  end)
end

local function find_base(on_found)
  find_pr(nil, function(pr_base, pr_url)
    if pr_base then
      return on_found(pr_base, pr_url)
    end
    -- a PR checked out under another name (pr-<n>, see the octo checkout above): gh finds a branch's PR by the
    -- branch's name or where it pushes to, so look it up by the name of the branch it tracks
    run({ 'git', 'rev-parse', '--abbrev-ref', 'HEAD', '@{u}' }, function(refs)
      local branch, upstream = (refs or ''):match('^(%S+)\n[^/]+/(%S+)$')
      if not upstream or upstream == branch then
        return find_default_branch(on_found)
      end
      find_pr(upstream, function(up_base, up_url)
        if up_base then
          return on_found(up_base, up_url)
        end
        find_default_branch(on_found)
      end)
    end)
  end)
end

-- PRDiff's progress in the message area (a progress-message, updated in place); safe from vim.system callbacks
local function prdiff_progress(msg, status)
  vim.schedule(function()
    vim.api.nvim_echo({ { msg } }, status ~= 'running', {
      id = 'config.prdiff',
      kind = 'progress',
      source = 'config.prdiff',
      title = 'PRDiff',
      status = status,
      err = status == 'failed' or nil,
    })
  end)
end

-- set while :PRDiff is looking up the base and fetching, so a second :PRDiff doesn't start another run
local prdiff_running = false

-- Diffview of the current branch against its PR's base (or the default branch before there is a PR).
-- In its tab, gitsigns also diffs the real files against the merge base, so ]c / [c walk the branch's changes.
vim.api.nvim_create_user_command('PRDiff', function()
  if prdiff_running then
    vim.notify('PRDiff: already running', vim.log.levels.WARN)
    return
  end
  prdiff_running = true
  prdiff_progress('finding the PR base…', 'running')
  find_base(function(base, pr_url)
    if not base then
      prdiff_running = false
      prdiff_progress('no PR for this branch and no default branch found', 'failed')
      return
    end
    prdiff_progress('fetching origin/' .. base .. '…', 'running')
    vim.system({ 'git', 'fetch', 'origin', base }, {}, function()
      prdiff_progress('finding the merge base…', 'running')
      run({ 'git', 'merge-base', 'origin/' .. base, 'HEAD' }, function(merge_base)
        vim.schedule(function()
          prdiff_running = false
          vim.cmd('DiffviewOpen origin/' .. base .. '...HEAD --imply-local')
          -- the Diffview tab's PR, for WakaTime (lua/plugins/wakatime.lua)
          vim.t.pr_url = pr_url
          if merge_base then
            tab_base[vim.api.nvim_get_current_tabpage()] = merge_base
            sync_review_base()
          end
          prdiff_progress(
            (pr_url and 'diffing against origin/' or 'no PR for this branch; diffing against origin/') .. base,
            'success'
          )
        end)
      end)
    end)
  end)
end, { desc = 'Diffview of the current branch against its PR base or the default branch' })
