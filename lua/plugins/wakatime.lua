-- WakaTime: time in a review (an Octo review tab, an Octo PR page, a Diffview tab) is sent as "code reviewing",
-- and Octo pages as the PR's GitHub URL (vim-wakatime sends their octo:// names, which wakatime-cli drops as
-- missing files). vim-wakatime runs scripts/wakatime-cli instead of the real CLI; Neovim writes when a review
-- was current to a file, and the wrapper tags each heartbeat by its time. Must run before vim-wakatime's
-- plugin/ script (it calls setup() once; later cli_path changes are ignored).

local uv = vim.uv
local home = vim.env.WAKATIME_HOME and vim.fn.expand(vim.env.WAKATIME_HOME) or uv.os_homedir()

-- the CLI vim-wakatime would pick on its own (same order)
local function real_cli()
  local found = vim.fn.exepath('wakatime-cli')
  if found ~= '' then
    return found
  end
  found = vim.fn.exepath('wakatime')
  if found ~= '' and not found:find('npm') and not found:find('node') then
    return found
  end
  for _, path in ipairs({
    home .. '/.wakatime/wakatime-cli',
    '/opt/homebrew/bin/wakatime-cli',
    '/usr/local/bin/wakatime-cli',
  }) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end
end

local cli = real_cli()
-- on a fresh machine vim-wakatime installs the CLI itself; the wrapper takes over from the next start
if not cli then
  return
end

local state_dir = vim.fn.stdpath('state') .. '/wakatime'
vim.fn.mkdir(state_dir, 'p')
local review_file = ('%s/review-%d'):format(state_dir, uv.os_getpid())
-- left behind on exit (vim-wakatime's last send runs after Neovim quits); remove old ones
for name in vim.fs.dir(state_dir) do
  local stat = uv.fs_stat(state_dir .. '/' .. name)
  if name:match('^review%-') and stat and stat.mtime.sec < os.time() - 86400 then
    os.remove(state_dir .. '/' .. name)
  end
end
vim.env.NVIM_WAKATIME_CLI = cli
vim.env.NVIM_WAKATIME_NVIM = vim.v.progpath
vim.env.NVIM_WAKATIME_REVIEW_FILE = review_file

-- repo is owner/name, or host/owner/name as in octo:// names for a GitHub Enterprise host
local function pr_url(repo, number)
  local host, rest = repo:match('^([^/]*%.[^/]*)/(.+)$')
  if not host then
    host = require('octo.config').values.github_hostname
    host = host ~= '' and host or 'github.com'
  end
  return ('https://%s/%s/pull/%s'):format(host, rest or repo, number)
end

-- The PR reviewed in the current tab or buffer: its URL ('' for a Diffview tab with no known PR), nil when not
-- reviewing. :PRDiff sets its Diffview tab's vim.t.pr_url.
local function current_review()
  local octo_review = package.loaded['octo.reviews'] and require('octo.reviews').get_current_review()
  if octo_review then
    return pr_url(octo_review.pull_request.repo, octo_review.pull_request.number)
  end
  local repo, number = vim.api.nvim_buf_get_name(0):match('^octo://(.+)/pull/(%d+)$')
  if repo then
    return pr_url(repo, number)
  end
  if package.loaded['diffview'] and require('diffview.lib').get_current_view() then
    return vim.t.pr_url or ''
  end
end

-- review periods, oldest first: { start, stop (exclusive; nil = still current), pr }
local periods = {}

local function write_periods()
  local lines = {}
  for _, p in ipairs(periods) do
    table.insert(lines, ('%d %s %s'):format(p[1], p[2] or '-', p[3] ~= '' and p[3] or '-'))
  end
  vim.fn.writefile(lines, review_file)
end

local function update()
  local pr = current_review()
  local last = periods[#periods]
  local open = last and not last[2] and last
  if open and open[3] == pr then
    return
  end
  -- whole seconds, like vim-wakatime's heartbeat times (localtime())
  local now = os.time()
  if open then
    open[2] = now
  end
  if pr then
    table.insert(periods, { now, nil, pr })
  end
  -- vim-wakatime sends within a minute or so; keep a day's worth
  while #periods > 0 and periods[1][2] and periods[1][2] < now - 86400 do
    table.remove(periods, 1)
  end
  write_periods()
end

local group = vim.api.nvim_create_augroup('WakaTimeReview', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'TabEnter', 'TabClosed' }, {
  group = group,
  callback = function()
    -- now, so vim-wakatime's heartbeat for this BufEnter falls inside the period; again once the event is
    -- over, because a closed tab is still current during TabClosed and octo registers a review after
    -- entering its tab
    update()
    vim.schedule(update)
  end,
})

-- after the autocmds above, so a period starts before vim-wakatime's BufEnter heartbeat
require('wakatime').setup({ cli_path = vim.fn.stdpath('config') .. '/scripts/wakatime-cli' })
