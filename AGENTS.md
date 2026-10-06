# AGENTS.md

Personal Neovim config (Lua), meant to be cloned to `~/.config/nvim`. Targets Neovim 0.12.

`README.md` documents install steps and keymaps. Update it whenever you change
`lua/keys.lua` or the install requirements.

## Layout and load order

- Plugins are managed by Neovim's built-in **`vim.pack`** (not packer, not lazy.nvim).
  `init.lua` requires `vars` → `opts` → `plug` → `keys`, then does plugin setup.
  `vim.pack.add()` in `lua/plug.lua` installs missing plugins synchronously, so everything
  after it can `require` plugins.
- **Almost all plugin `setup()` calls, LSP, cmp, DAP, treesitter and none-ls config live
  inline in `init.lua`**, not in separate modules.
- `lua/plug.lua` — the `vim.pack.add({...})` list, in load order (no dependency field:
  list a dependency before its dependents). Branch pins use `version = '<branch>'`.
  Build steps are `PackChanged` autocmd hooks registered **before** `vim.pack.add()`;
  call the plugin's Lua API there (`packadd` it first if `ev.data.active` is false).
  During `init.lua`, `vim.pack.add()` doesn't source `plugin/` files yet, so plugin
  commands don't exist until startup finishes.
- `nvim-pack-lock.json` is the lockfile written by `vim.pack`. Commit it with any plugin
  change; never edit it by hand.
- `lua/keys.lua` — all keymaps. It `require`s telescope/dap at load time. LSP buffer-local
  maps are set in its `LspAttach` autocmd.
- `ftplugin/java.lua` — the entire Java/jdtls + Java DAP setup (nvim-jdtls), not `init.lua`.
- `ftplugin/sql.lua`, `ftplugin/dbout.lua` — dadbod-ui buffer maps (`dbout` overrides `gd`).
- `ftdetect/filetype.lua` — `*.yaml.gotmpl` / `*.yml.gotmpl` → `helm`.
- `colors/darcula-solid-ex.lua` — wraps `darcula-solid`; put highlight overrides here.
- `.ideavimrc` is for JetBrains IdeaVim and has nothing to do with Neovim.

## LSP / formatting gotchas

- Servers use the native `vim.lsp.config()` + `vim.lsp.enable()` API. `mason-lspconfig` has
  `automatic_enable = false`, so a server only runs if `init.lua` enables it explicitly.
  Mason installs servers through `mason-lspconfig.ensure_installed` and other tools
  (formatters, debug adapters) through `mason-tool-installer.ensure_installed`.
- Format-on-save only happens for clients attached with `on_attach_lsp_format`
  (lsp-format.nvim). If a server's config doesn't pass it, that server never formats.
- Rust is configured through `vim.g.rustaceanvim`, not lspconfig.
- none-ls formats Lua with stylua, SQL with sqlfluff (`--dialect postgres`), and everything
  else with prettierd. prettierd is turned off for yaml and for the filetypes biome handles,
  and turned on for `java` (jdtls formatting is disabled so prettier-java is used).
- Treesitter uses the main-branch API (`require('nvim-treesitter').install(...)`) plus a
  `FileType` autocmd that calls `vim.treesitter.start()`. A new language must be added
  to the `ts_files` list or it gets no treesitter highlighting.
- `Comment.nvim` is pinned to the fork `faergeek/Comment.nvim` on branch
  `nvim-0.12-compatibility`. Don't switch it back to upstream.

## Style and verification

- Use StyLua (`.stylua.toml`): 2 spaces, single quotes, 120 columns, and parentheses on
  every call, e.g. `require('x')` and `use('a/b')`, never `require 'x'`. Run `stylua .`
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
