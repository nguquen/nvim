# nvim

My Neovim config, written in Lua. Plugins are managed with Neovim's built-in
[`vim.pack`](https://neovim.io/doc/user/pack.html#vim.pack).

# 1. Installation

## Requirements

- Neovim **0.12+**
- `git`, [ripgrep](https://github.com/BurntSushi/ripgrep) (Telescope grep)
- [`tree-sitter` CLI](https://github.com/tree-sitter/tree-sitter) and a C compiler. nvim-treesitter compiles its parsers locally.
- A [Nerd Font](https://www.nerdfonts.com/) set in your terminal, for the icons
- Language toolchains for the languages you use (`node`/`npm`, `go`, `python3`, `java`, `cargo`). Mason needs them to install servers and tools.
- Optional: [`gh`](https://cli.github.com/) (Octo, `:PRDiff`), [`lazygit`](https://github.com/jesseduffield/lazygit), [`helmfmt`](https://github.com/digitalis-io/helmfmt) (Helm formatting)

## Install

```sh
git clone https://github.com/nguquen/nvim.git ~/.config/nvim
```

Start `nvim` and confirm the prompt to install the plugins. They are installed at the
revisions pinned in `nvim-pack-lock.json`, and the rest of the config loads straight after.
On that start:

- Treesitter parsers are compiled.
- Mason installs every language server turned on in `lua/config/lsp.lua` (plus `jdtls`) and the extra tools listed in `lua/plugins/mason.lua` (formatters, linters, debug adapters).

To install the plugins without a UI (e.g. in a script), run:

```sh
nvim --headless +qa
```

Check the setup with `:checkhealth`.

## Updating plugins

```vim
:lua vim.pack.update()
```

This opens a buffer listing the pending changes. `:write` applies them, `:quit` cancels.
Then `:restart` and commit the updated `nvim-pack-lock.json`.

After pulling a lockfile change from another machine, restart Neovim to install new plugins,
then bring the existing ones to the locked revisions:

```vim
:lua vim.pack.update(nil, { target = 'lockfile' })
```

To remove a plugin, delete it from `lua/config/pack.lua`, restart, then run
`:lua vim.pack.del({ 'plugin-name' })`.

## Migrating from packer.nvim

This config used packer.nvim before. On a machine set up back then, remove packer's copies,
or they keep loading alongside the new ones:

```sh
rm -rf ~/.local/share/nvim/site/pack/packer ~/.config/nvim/plugin/packer_compiled.lua
```

# 2. Layout

| Path | Contents |
| --- | --- |
| `init.lua` | Leader, then loads the modules below in order |
| `lua/config/options.lua` | Options and globals |
| `lua/config/pack.lua` | Plugin list (`vim.pack.add`) and build hooks |
| `nvim-pack-lock.json` | Plugin lockfile, written by `vim.pack` |
| `lua/config/keymaps.lua` | Keymaps |
| `lua/config/lsp.lua` | Language servers to enable, format-on-save list, shared LSP setup |
| `after/lsp/<server>.lua` | Settings for one language server |
| `lua/plugins/*.lua` | Plugin setup, one file per area (ui, navigation, editing, git, completion, dap, …) |
| `ftplugin/<filetype>.lua` | Per-language setup: Java (jdtls + debugger), Rust (rust-analyzer), `Cargo.toml` (crates), Helm |
| `colors/darcula-solid-ex.lua` | Colorscheme: `darcula-solid` with personal overrides |

# 3. Key mapping

Leader is `space`. Arrow keys are turned off. List every mapping with `space km`.

## General

```
space w / space q / space x : write / quit / write+quit
space h/j/k/l               : move to left/down/up/right window
ctrl-h/j/k/l                : move between windows and tmux panes (vim-tmux-navigator)
space ch                    : clear search highlight
space p                     : paste last yank ("0)
ctrl-n                      : toggle file tree (nvim-tree)
gcc / gc{motion}            : toggle line comment
gbc / gb{motion}            : toggle block comment
```

## Telescope

```
ctrl-p    : find files
space g   : live grep
space s   : grep word under cursor
space b   : fuzzy find in current buffer
space o   : document symbols
space d   : diagnostics
space [   : location list
space ]   : quickfix list
space \   : git commits for current buffer
space rl  : resume previous picker
```

Inside a picker, `ctrl-j` and `ctrl-k` move the selection and `esc` closes it.

## LSP

```
gd / gD   : definition / type definition
gr / gi   : references / implementations
K         : hover docs (crate features in Cargo.toml)
space rn  : rename
alt-enter : code action
[d / ]d   : previous / next diagnostic
```

Files are formatted on save by the language server or none-ls.

## Completion

```
tab        : confirm (select the first item if none is selected) / expand or jump snippet
enter      : confirm the selected item
ctrl-j/k   : next / previous item
ctrl-space : trigger completion
ctrl-e     : close menu
```

## Debugging (nvim-dap)

```
F5 / shift-F5 : continue / terminate
F9            : toggle breakpoint
F10 / F11 / F12 : step over / into / out
F2            : close DAP UI
```

## Git / GitHub

```
space op : list PRs (Octo)
space od : diff current PR against its base (:PRDiff)
space or : start review       space oR : resume review
space os : submit review
space dh : file history (Diffview)
space dc : close Diffview
```

## Database (vim-dadbod-ui)

```
space dw : save query (sql buffers)
gd       : jump to foreign key (result buffers)
```

# 4. tmux

[vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) lets `ctrl-h/j/k/l`
move between Neovim windows and tmux panes. Add this to `~/.tmux.conf`:

```
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind -n C-h if-shell "$is_vim" "send-keys C-h"  "select-pane -L"
bind -n C-j if-shell "$is_vim" "send-keys C-j"  "select-pane -D"
bind -n C-k if-shell "$is_vim" "send-keys C-k"  "select-pane -U"
bind -n C-l if-shell "$is_vim" "send-keys C-l"  "select-pane -R"
bind -n 'C-\' if-shell "$is_vim" 'send-keys C-\\' 'select-pane -l'
```
