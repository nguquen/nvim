# nvim

My Neovim config, written in Lua and managed with [packer.nvim](https://github.com/wbthomason/packer.nvim).

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

Start `nvim`. The first start installs packer and all plugins, then asks you to restart.
On the next start:

- Treesitter parsers are compiled.
- Mason installs the language servers listed in `init.lua` and the extra tools (formatters, linters, debug adapters).

To install the plugins without a UI (e.g. in a script), run:

```sh
nvim --headless -c 'autocmd User PackerComplete quitall'
```

Check the setup with `:checkhealth`.

`jsonls`, `biome` and `helm_ls` are turned on in `init.lua`, but Mason doesn't install them.
Install them yourself if you need them:

```vim
:MasonInstall json-lsp biome helm-ls
```

## Updating plugins

```vim
:PackerSync
```

# 2. Layout

| Path | Contents |
| --- | --- |
| `init.lua` | Bootstrap, plus almost all plugin setup (LSP, completion, DAP, treesitter, none-ls, …) |
| `lua/plug.lua` | Plugin list |
| `lua/keys.lua` | Keymaps |
| `lua/opts.lua`, `lua/vars.lua` | Options and globals |
| `ftplugin/java.lua` | Java (jdtls) LSP + debugger |
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
