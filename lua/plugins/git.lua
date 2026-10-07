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
  find_base(function(base, is_pr)
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
          if merge_base then
            tab_base[vim.api.nvim_get_current_tabpage()] = merge_base
            sync_review_base()
          end
          prdiff_progress(
            (is_pr and 'diffing against origin/' or 'no PR for this branch; diffing against origin/') .. base,
            'success'
          )
        end)
      end)
    end)
  end)
end, { desc = 'Diffview of the current branch against its PR base or the default branch' })
