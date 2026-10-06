# AGENTS.md

Personal Neovim config (Lua), meant to be cloned to `~/.config/nvim`. Targets Neovim 0.12.

`README.md` documents install steps and keymaps. Update it whenever you change
`lua/config/keymaps.lua` or the install requirements.

## Layout and load order

- `init.lua` only sets the leader and `require`s modules in order: `config.options` →
  `config.pack` → `config.keymaps` → `plugins.*` / `config.lsp`. Order matters:
  `config.lsp` must load before `plugins.lang` and `plugins.formatting`, which use its
  `format_on_attach`. A new `lua/plugins/<area>.lua` does nothing until `init.lua` requires it.
- `lua/plugins/<area>.lua` — plain `setup()` calls grouped by area (ui, navigation, editing,
  git, mason, lang, dap, completion, treesitter, formatting, db). These are not lazy.nvim
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
  buffer-local maps are set in its `LspAttach` autocmd.
- `ftplugin/java.lua` — the entire Java/jdtls + Java DAP setup (nvim-jdtls).
- `ftplugin/sql.lua`, `ftplugin/dbout.lua` — dadbod-ui buffer maps (`dbout` overrides `gd`).
- `ftdetect/filetype.lua` — `*.yaml.gotmpl` / `*.yml.gotmpl` → `helm`.
- `colors/darcula-solid-ex.lua` — wraps `darcula-solid`; put highlight overrides here.
- `.ideavimrc` is for JetBrains IdeaVim and has nothing to do with Neovim.

## LSP / formatting gotchas

- Servers use the native `vim.lsp.config()` + `vim.lsp.enable()` API. `mason-lspconfig` has
  `automatic_enable = false`, so a server only runs if it's in the `vim.lsp.enable({...})`
  list in `lua/config/lsp.lua`. Mason installs servers through
  `mason-lspconfig.ensure_installed` and other tools (formatters, debug adapters) through
  `mason-tool-installer.ensure_installed` (both in `lua/plugins/mason.lua`).
- Per-server settings go in `after/lsp/<server>.lua`, returning a config table. It must be
  `after/lsp/`, not `lsp/`: a plain `lsp/` file is overridden by nvim-lspconfig's own
  `lsp/<server>.lua`. Don't set `on_attach` there: for servers in the format list,
  `config/lsp.lua` sets it with higher priority and the file's value is ignored.
- Completion capabilities are set once for every server with `vim.lsp.config('*', ...)`.
- Format-on-save only happens for servers in the format list in `lua/config/lsp.lua`, which
  attaches lsp-format.nvim. A server missing from that list never formats.
- Rust is configured through `vim.g.rustaceanvim` in `lua/plugins/lang.lua`, not lspconfig.
- none-ls (`lua/plugins/formatting.lua`) formats Lua with stylua, SQL with sqlfluff
  (`--dialect postgres`), and everything else with prettierd. prettierd is turned off for
  yaml and for the filetypes biome handles, and turned on for `java` (jdtls formatting is
  disabled so prettier-java is used).
- Treesitter uses the main-branch API (`require('nvim-treesitter').install(...)`) plus a
  `FileType` autocmd that calls `vim.treesitter.start()`. A new language must be added
  to the `ts_files` list in `lua/plugins/treesitter.lua` or it gets no treesitter highlighting.
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
