# AGENTS.md

Personal Neovim config (Lua), meant to be cloned to `~/.config/nvim`. Targets Neovim 0.12.

`README.md` documents install steps and keymaps. Update it whenever you change
`lua/keys.lua` or the install requirements.

## Layout and load order

- `init.lua` bootstraps **packer.nvim** (not lazy.nvim), then requires `vars` → `opts` →
  `plug`. On the first run it starts `PackerSync` and returns there; `keys` and every
  plugin `require`/`setup()` must stay **below** that `if packer_bootstrap` early return,
  or a fresh install fails before plugins exist.
- **Almost all plugin `setup()` calls, LSP, cmp, DAP, treesitter and none-ls config live
  inline in `init.lua`**, not in separate modules.
- `lua/plug.lua` — plugin list (`use(...)`). Adding a plugin = `use()` here + setup in
  `init.lua`; the user installs with `:PackerSync`. Packer's post-install key is `run`,
  not lazy.nvim's `build` (which packer silently ignores). Prefer a Lua function over an
  `':Command'` string: on a fresh install the plugin's commands aren't defined yet.
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
  `nvim --headless -c 'autocmd User PackerComplete quitall'`, then check with
  `nvim --headless +'sleep 3' +messages +qa`. The
  devcontainer has no `tree-sitter` CLI, so parser-compile errors there are expected.
