-- Runs the real wakatime-cli ($NVIM_WAKATIME_CLI) for vim-wakatime, changing the heartbeats it sends:
-- - a heartbeat made while a review was current (periods in $NVIM_WAKATIME_REVIEW_FILE, written by
--   lua/plugins/wakatime.lua) gets the category "code reviewing", unless it already has one (debugging);
-- - an octo:// entity becomes a URL: the PR / issue / discussion page's, or for a review buffer the PR's.
-- Everything else (and every non-heartbeat command) passes through unchanged.

local args = { os.getenv('NVIM_WAKATIME_CLI') }
vim.list_extend(args, _G.arg)

local function flag_index(name)
  for i = 2, #args do
    if args[i] == name then
      return i
    end
  end
end

-- { start, stop (exclusive; nil = still current), pr URL or nil }, in whole seconds like vim-wakatime's times
local periods = {}
local review_file = os.getenv('NVIM_WAKATIME_REVIEW_FILE')
if review_file and vim.uv.fs_stat(review_file) then
  for line in io.lines(review_file) do
    local start, stop, pr = line:match('^(%S+) (%S+) (%S+)$')
    if start then
      table.insert(periods, { tonumber(start), tonumber(stop), pr ~= '-' and pr or nil })
    end
  end
end

local function period_at(time)
  time = tonumber(time)
  for i = #periods, 1, -1 do
    local p = periods[i]
    if time and time >= p[1] and (not p[2] or time < p[2]) then
      return p
    end
  end
end

local kinds = { pull = 'pull', issue = 'issues', discussion = 'discussions' }

-- URL and repo name for an octo:// entity, or nil
local function octo_url(entity, period)
  local path = entity:match('^octo://(.+)$')
  if not path then
    return
  end
  local parts = vim.split(path, '/')
  local host = parts[1]:find('%.') and table.remove(parts, 1) or 'github.com'
  local owner, repo, kind, number = parts[1], parts[2], parts[3], parts[4]
  if kinds[kind] and number and number:match('^%d+$') then
    return ('https://%s/%s/%s/%s/%s'):format(host, owner, repo, kinds[kind], number), repo
  end
  if kind == 'review' and period and period[3] then
    return period[3], repo
  end
end

-- set once a heartbeat in this send is tagged as a review
local reviewing = false

-- heartbeat fields: entity, time, category, entity_type, alternate_project; returns the changed ones
local function change(hb)
  local period = period_at(hb.time)
  local new = {}
  if period and not hb.category then
    new.category = 'code reviewing'
    reviewing = true
  end
  local url, repo = octo_url(hb.entity, period)
  if url then
    new.entity, new.entity_type, new.alternate_project = url, 'url', repo
  end
  return new
end

local function present(value)
  return value ~= vim.NIL and value or nil
end

local entity_i = flag_index('--entity')
local stdin = flag_index('--extra-heartbeats') and io.read('*a') or nil
if entity_i then
  local category_i = flag_index('--category')
  local time_i = flag_index('--time')
  local new = change({
    entity = args[entity_i + 1],
    time = time_i and args[time_i + 1],
    category = category_i and args[category_i + 1],
  })
  if new.entity then
    args[entity_i + 1] = new.entity
    vim.list_extend(args, { '--entity-type', new.entity_type, '--alternate-project', new.alternate_project })
  end
  if new.category then
    vim.list_extend(args, { '--category', new.category })
  end

  local ok, extra = pcall(vim.json.decode, stdin or '')
  if ok and type(extra) == 'table' and #extra > 0 then
    for _, hb in ipairs(extra) do
      local changed = change({
        entity = hb.entity,
        time = present(hb.timestamp) or present(hb.time),
        category = present(hb.category),
      })
      hb.category = changed.category or hb.category
      if changed.entity then
        hb.entity, hb.entity_type, hb.alternate_project = changed.entity, changed.entity_type, changed.alternate_project
      end
    end
    stdin = vim.json.encode(extra) .. '\n'
  end
end

-- The CLI reads AI agents' logs on every send, and relabels the send's heartbeats near AI activity as "ai coding"
-- (OpenCode working while you review). Skip that for a send with review heartbeats; the next send reads the logs.
-- Older CLIs don't know the flag (and don't relabel), so retry without it.
local result
if reviewing then
  result = vim.system(vim.list_extend(vim.list_slice(args), { '--sync-ai-disabled' }), { stdin = stdin }):wait()
  if result.code ~= 0 and (result.stderr or ''):find('unknown flag') then
    result = nil
  end
end
result = result or vim.system(args, { stdin = stdin }):wait()
io.stdout:write(result.stdout or '')
io.stderr:write(result.stderr or '')
os.exit(result.code)
