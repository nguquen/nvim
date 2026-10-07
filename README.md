# nvim

My Neovim config, written in Lua. Plugins are managed with Neovim's built-in
[`vim.pack`](https://neovim.io/doc/user/pack.html#vim.pack).

# 1. Installation

## Requirements

- Neovim **0.12+**
- `git`, [ripgrep](https://github.com/BurntSushi/ripgrep) (Telescope grep)
- [`tree-sitter` CLI](https://github.com/tree-sitter/tree-sitter) 0.26.1 or newer, and a C compiler. nvim-treesitter compiles its parsers locally.
- A [Nerd Font](https://www.nerdfonts.com/) set in your terminal, for the icons
- Language toolchains for the languages you use (`node`/`npm`, `go`, `python3`, `java`, `cargo`). Mason needs them to install servers and tools.
- For Go, `gopls` and `dlv` on your `PATH`; Mason doesn't install them:
  ```sh
  go install golang.org/x/tools/gopls@latest
  go install github.com/go-delve/delve/cmd/dlv@latest
  ```
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
| `lua/config/lsp.lua` | Language servers to enable, format-on-save list, shared LSP setup, none-ls (formatters, linters) |
| `after/lsp/<server>.lua` | Settings for one language server |
| `lua/plugins/*.lua` | Plugin setup, one file per area (ui, navigation, editing, git, completion, dap, …) |
| `ftplugin/<filetype>.lua` | Per-language setup: Java (jdtls + debugger), `Cargo.toml` (crates), Helm, Lua (lazydev) |
| `colors/darcula-solid-ex.lua` | Colorscheme: `darcula-solid` with personal overrides |
| `scripts/wakatime-cli` | Wrapper vim-wakatime runs instead of wakatime-cli (tags PR review time) |

# 3. Key mapping

Leader is `space`. Arrow keys are turned off. List every mapping with `space km`.

Yanks go to the system clipboard through the terminal (OSC 52), which also works over
SSH. `p` pastes what Neovim last yanked; to paste from other apps, use the terminal's
paste shortcut (Cmd-V / Ctrl-Shift-V) or `space y`.

## General

```
space w / space q / space x : write / quit / write+quit
space h/j/k/l               : move to left/down/up/right window
ctrl-h/j/k/l                : move between windows and tmux panes (vim-tmux-navigator)
space ch                    : clear search highlight
space p                     : paste last yank ("0)
space y                     : put the system clipboard in "0 (terminal must allow OSC 52 reads)
ctrl-n                      : toggle file tree (nvim-tree)
gcc / gc{motion}            : toggle line comment
gbc / gb{motion}            : toggle block comment
Q{reg} … Q                  : record a macro (q alone does nothing; Q: opens the command-line window)
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
space rf  : refactor: extract/inline variable or function (visual selection, or a motion)
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
space rp : list PRs (Octo)
space rd : diff current branch against its PR's base, or the default branch if no PR yet (:PRDiff)
space rr : start review       space rR : resume review
space rs : submit review
space rh : file history (Diffview)
space rc : close Diffview
]c / [c  : next / previous change (diff windows) or git hunk (other buffers)
]q / [q  : next / previous file (Diffview and Octo review)
[Q / ]Q  : first / last file (Diffview and Octo review)
```

In the `:PRDiff` tab, the git signs on the real files compare against the same base, so `]c` / `[c`
walk the branch's changes there; other tabs keep comparing against `HEAD`.
With no PR, the base is `origin/HEAD` (set by `git clone`; `git remote set-head origin -a` sets it
later), else GitHub's default branch. While it looks up the base and fetches, the message line shows
which step it is on.
Octo reviews show the real file on the right (LSP works there) and offer to check out the PR branch
first; say yes, or the right side is a read-only copy. On the real file, the git signs compare against
the PR's base (not `HEAD`, which is the PR itself), only in the review tab. Octo reviews use the same
diff colours as Diffview and show the changed files on the left, like Diffview. Octo merges squash by default.

WakaTime counts time in an Octo review, on an Octo PR page or in a Diffview tab as **Code Reviewing**,
and Octo pages and the base side of a `:PRDiff` as the PR's GitHub page under the repo's project
(wakatime-cli would otherwise drop them).

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
