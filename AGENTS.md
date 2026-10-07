# AGENTS.md

Personal Neovim config (Lua), meant to be cloned to `~/.config/nvim`. Targets Neovim 0.12.

`README.md` documents install steps and keymaps. Update it whenever you change
`lua/config/keymaps.lua` or the install requirements.

## Layout and load order

- `init.lua` only sets the leader and `require`s modules in order: `config.options` →
  `config.pack` → `config.keymaps` → `plugins.*` / `config.lsp`. Order matters:
  `config.lsp` must load before `plugins.mason` (reads its `servers` list). A new
  `lua/plugins/<area>.lua` does nothing until `init.lua` requires it.
- `lua/plugins/<area>.lua` — plain `setup()` calls grouped by area (ui, navigation, editing,
  git, mason, dap, completion, treesitter, db). These are not lazy.nvim
  plugin specs; there is no lazy loading.
- Plugins are managed by Neovim's built-in **`vim.pack`** (not packer, not lazy.nvim).
  `vim.pack.add()` in `lua/config/pack.lua` installs missing plugins synchronously, so
  everything after it can `require` plugins.
- `lua/config/pack.lua` — the `vim.pack.add({...})` list, in load order (no dependency field:
  list a dependency before its dependents). Branch pins use `version = '<branch>'`.
  Build steps are `PackChanged` autocmd hooks registered **before** `vim.pack.add()`;
  call the plugin's Lua API there (`packadd` it first if `ev.data.active` is false).
  During `init.lua`, `vim.pack.add()` doesn't source `plugin/` files yet, so plugin
  commands don't exist until startup finishes.
- `nvim-pack-lock.json` is the lockfile written by `vim.pack`. Commit it with any plugin
  change; never edit it by hand.
- `lua/config/keymaps.lua` — all keymaps. It `require`s telescope/dap at load time. LSP
  buffer-local maps are set in its `LspAttach` autocmd. Review keys (octo, diffview) live
  under `<leader>r`. Don't map a bare `<leader>x` that is also the start of a longer map
  (it waits `timeoutlen`); `<leader>o` and `<leader>d` are bare maps, so keep groups off them.
- `lua/plugins/git.lua` — gitsigns, octo, diffview, `diffopt`, and `:PRDiff`. `:PRDiff`
  diffs against the PR's base branch, or with no PR `origin/HEAD`, else GitHub's default
  branch; it runs those lookups and `git fetch` with `vim.system` callbacks (never blocking).
  It sets gitsigns' base to the merge base for all buffers; diffview's `view_closed` hook
  resets it. In an Octo review, the right-side real file (`use_local_fs`) gets a per-buffer
  gitsigns base = the PR's merge base (`b:review_base`), reset on `TabClosed`. Octo has no
  review events, so this reads octo internals (`b:octo_diff_props`,
  `require('octo.reviews').get_current_review().pull_request.left.commit`); recheck after
  octo updates. The base is applied on gitsigns' `User GitSignsUpdate`, because a
  `change_base` while gitsigns is still attaching is lost. The same file also wraps
  `require('octo').update_layout_for_current_file` to work around an octo `use_local_fs`
  BufEnter recursion (shows as "No matching autocommands: filetypedetect BufRead");
  drop it once octo fixes that. It also wraps octo's `Layout.init_layout` to relink the
  diff groups in octo's review highlight namespaces to Diffview's (`enhanced_diff_hl`), so
  both views colour diffs the same.
- `ftplugin/<filetype>.lua` — setup for one language, run when a buffer of that filetype
  opens (config dir comes first on the runtimepath, so these run before the plugins' own
  ftplugins). Global one-time `setup()` calls here need a `vim.g` guard.
  - `java.lua` — the entire Java/jdtls + Java DAP setup (nvim-jdtls).
  - `toml.lua` — crates.nvim, for `Cargo.toml` only.
  - `helm.lua` — helm-ls.nvim (template highlights/hints; the server is `helm_ls`).
  - `lua.lua` — lazydev.nvim, which gives lua_ls the Neovim runtime plus the plugins a
    file `require()`s (off in projects with their own `.luarc.json(c)`).
- `ftplugin/sql.lua`, `ftplugin/dbout.lua` — dadbod-ui buffer maps (`dbout` overrides `gd`).
- `ftdetect/filetype.lua` — `*.yaml.gotmpl` / `*.yml.gotmpl` → `helm`.
- `colors/darcula-solid-ex.lua` — wraps `darcula-solid`; put highlight overrides here.
- `.ideavimrc` is for JetBrains IdeaVim and has nothing to do with Neovim.

## LSP / formatting gotchas

- Servers use the native `vim.lsp.config()` + `vim.lsp.enable()` API. `mason-lspconfig` has
  `automatic_enable = false`. Every server is one entry in the `servers` table in
  `lua/config/lsp.lua`: `{ name = ..., enable = bool, install = bool, format_on_save = bool }`.
  - `name` is the client name; for `enable`/`install` entries it must be the lspconfig
    name (and `install` needs a Mason package).
  - `enable = true` runs `vim.lsp.enable()`. `false` is for servers a plugin starts itself:
    jdtls (nvim-jdtls, `ftplugin/java.lua`) and rust-analyzer (rustaceanvim).
  - `install = true` puts it in `mason-lspconfig.ensure_installed`. `false` means it comes
    from PATH: rust-analyzer (rustup) and gopls (`go install`). delve is likewise left out of
    Mason's tool list; nvim-dap-go runs `dlv` from PATH. Mason's go installs fail on the
    owner's machine ("Tried to link bin ... to non-existent target": a go shim overrides
    Mason's `GOBIN`), so don't move them back to Mason.
  - `format_on_save = true` attaches lsp-format.nvim from an `LspAttach` autocmd matched
    by client name, so it works however the client was started. A server not marked
    never formats on save. none-ls is the `null-ls` entry (`enable`/`install = false`).
  Other tools (formatters, debug adapters) go in `mason-tool-installer.ensure_installed` in
  `lua/plugins/mason.lua`.
- Per-server settings go in `after/lsp/<server>.lua`, returning a config table. It must be
  `after/lsp/`, not `lsp/`: a plain `lsp/` file is overridden by nvim-lspconfig's own
  `lsp/<server>.lua`.
- Don't put `workspace.library`, `runtime` or `diagnostics.globals` in
  `after/lsp/lua_ls.lua`: lazydev.nvim sets them per workspace. Listing the whole
  runtimepath there (the old setup) made lua_ls take ~20 s and ~2.4 GB, and resolved
  `require('cmp')` to the wrong module.
- Completion capabilities are set once for every server with `vim.lsp.config('*', ...)`.
  nvim-jdtls doesn't read `vim.lsp.config`, so jdtls doesn't get them (nor any `after/lsp/`
  file); configure jdtls in `ftplugin/java.lua`.
- Rust's server is started by rustaceanvim, not `vim.lsp.enable()`. Configure it in
  `after/lsp/rust-analyzer.lua` (hyphen: rustaceanvim's client name, which it looks up in
  `vim.lsp.config` when starting the client), not lspconfig's `rust_analyzer`; never
  enable it or `rust_analyzer`. `vim.g.rustaceanvim` is unset; only add it for `tools`/`dap`
  options, and set it in `init.lua`, since rustaceanvim reads it once, possibly from a
  `Cargo.toml` buffer.
- none-ls (end of `lua/config/lsp.lua`) formats Lua with stylua, SQL with sqlfluff
  (`--dialect postgres`), and everything else with prettierd. prettierd is turned off for
  yaml, skipped in any buffer a `biome` client is attached to (projects with a
  `biome.json(c)`, see `after/lsp/biome.lua`), and turned on for `java` (jdtls formatting
  is disabled so prettier-java is used). eslint_d (diagnostics, code actions, and `--fix`
  on save after prettierd) only runs in projects with an eslint config.
- Treesitter uses the main-branch API (`require('nvim-treesitter').install(...)`) plus a
  `FileType` autocmd that calls `vim.treesitter.start()`. A new language must be added
  to the `ts_files` list in `lua/plugins/treesitter.lua` or it gets no treesitter highlighting.
- The clipboard (`lua/config/options.lua`) copies with OSC 52 but never reads it back: `p`
  pastes from a cache of the last copy. Don't switch `paste` to
  `vim.ui.clipboard.osc52.paste`: on terminals that don't answer OSC 52 reads every `p`
  hangs for 10 s. The owner accepted the tradeoff: `p` doesn't paste text copied in other
  apps (use the terminal's paste shortcut). Only `<leader>y` reads the system clipboard.
- `Comment.nvim` is pinned to the fork `faergeek/Comment.nvim` on branch
  `nvim-0.12-compatibility`. Don't switch it back to upstream.

## Style and verification

- Use StyLua (`.stylua.toml`): 2 spaces, single quotes, 120 columns, and parentheses on
  every call, e.g. `require('x')` and `gh('a/b')`, never `require 'x'`. Run `stylua .`
  (installed by Mason; it may not be on PATH).
- There are no tests and no CI. For a quick syntax check of every file:

  ```sh
  nvim --headless -u NONE -c 'lua for _,f in ipairs(vim.fn.globpath(".", "**/*.lua", false, true)) do local ok,e=loadfile(f); if not ok then print(e) end end' -c 'qa!'
  ```

- To load the full config, use an isolated sandbox. Symlink the repo to
  `$XDG_CONFIG_HOME/nvim`, and point `XDG_CONFIG_HOME`/`XDG_DATA_HOME`/`XDG_STATE_HOME`/
  `XDG_CACHE_HOME` at directories under `/tmp/opencode/`. Install with
  `nvim --headless +qa`, then check with
  `nvim --headless +'sleep 3' +messages +qa`. The
  devcontainer has no `tree-sitter` CLI, so parser-compile errors there are expected.
