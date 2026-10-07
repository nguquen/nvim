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
OctoLayout.init_layout = function(self)
  init_layout(self)
  for ns, groups in pairs(octo_review_hl) do
    for group, link in pairs(groups) do
      vim.api.nvim_set_hl(ns, group, { link = link })
    end
  end
end

-- In an Octo review, gitsigns on the right-side file (the real file, with use_local_fs) diffs against the
-- PR's merge base instead of HEAD, which is the PR head once it's checked out. Uses octo internals: Octo has
-- no review events, but it marks review buffers with b:octo_diff_props.

-- Applies b:review_base (nil = back to the default base) once gitsigns has finished its first update of the
-- buffer; a change_base during gitsigns' attach is lost.
local function apply_review_base(buf)
  local b = vim.b[buf]
  if b.review_base_applied == (b.review_base or false) or (b.gitsigns_status_dict or {}).added == nil then
    return
  end
  b.review_base_applied = b.review_base or false
  vim.api.nvim_buf_call(buf, function()
    require('gitsigns').change_base(b.review_base)
  end)
end

local review_group = vim.api.nvim_create_augroup('OctoReviewGitsigns', { clear = true })
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = review_group,
  callback = function(ev)
    local props = vim.b[ev.buf].octo_diff_props
    if not props or props.split ~= 'RIGHT' or vim.api.nvim_buf_get_name(ev.buf):match('^octo://') then
      return
    end
    local review = require('octo.reviews').get_current_review()
    local base = review and review.pull_request.left.commit
    if base then
      vim.b[ev.buf].review_base = base
      vim.b[ev.buf].review_tab = vim.api.nvim_get_current_tabpage()
      apply_review_base(ev.buf)
    end
  end,
})
vim.api.nvim_create_autocmd('User', {
  group = review_group,
  pattern = 'GitSignsUpdate',
  callback = function(ev)
    local buf = ev.data and ev.data.buffer
    if buf and vim.b[buf].review_tab then
      apply_review_base(buf)
    end
  end,
})
vim.api.nvim_create_autocmd('TabClosed', {
  group = review_group,
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local tab = vim.b[buf].review_tab
      if tab and not vim.api.nvim_tabpage_is_valid(tab) then
        vim.b[buf].review_base = nil
        vim.b[buf].review_tab = nil
        if vim.api.nvim_buf_is_loaded(buf) then
          apply_review_base(buf)
        end
        vim.b[buf].review_base_applied = nil
      end
    end
  end,
})

-- set while :PRDiff has moved gitsigns' base to the PR's merge base
local pr_base_set = false

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
