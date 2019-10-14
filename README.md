# 1. Installation

## Install iTerm2

```
https://www.iterm2.com/downloads.html
```

## Install neovim:
```
$ brew install neovim
```

## Create symlink:

```
$ ln -s /usr/local/bin/nvim /usr/local/bin/vi
```

## Install python:

```
$ brew install python
$ brew install python3
```

## Install python providers:

```
$ pip install pynvim
$ pip3 install pynvim
```

## Open neovim & check health:

```
$ vi
```

Inside vim, type this command:

```
:checkhealth
```

## Checkout pre-config:

```
$ mkdir ~/.config
$ cd ~/.config
$ git clone https://github.com/nguquen/nvim.git
```

The detail config inside this file: `~/.config/nvim/init.vim`

## Install vim plugins:

```
$ vi
```

Inside vim:

```
:PlugInstall
```

## Install powerline fonts:

`vim-airline` use powerline fonts for display some special characters like arrow, install it here:
[https://github.com/powerline/fonts](https://github.com/powerline/fonts). Choose a font that you like and install it for iTerm2.

## Install RipGrep:
```
brew install ripgrep
```

# 2. Key mapping
Some basic key mapping of the plugins. For more detail, check the document of each plugin.

## NERD Tree

Use `ctrl-n` to toggle file explorer

Inside nerdtree window, type `?` for help

## Ctrl-P

Use `ctrl-p` to open fuzzy finder

## NERD Commenter

Comment: `space-cc`

Uncomment: `space-cu`

## Working with ctags

> Ctags generates an index (or tag) file of language objects found in source files that allows these items to be quickly and easily located by a text editor or other utility.

It's not work well with javascript, that's why we should use flow :D. But it's still helpful if we're working with Ruby or other languages.

Install ctags

```
$ brew install ctags
```

Add ctags rule for Rails

```
$ vi ~/.ctags

--regex-ruby=/(^|;)[ \t]*(class|module)[ \t]+([A-Z][[:alnum:]_]+(::[A-Z][[:alnum:]_]+)+)/\3/c,class,constant/
--regex-ruby=/(^|[:;])[ \t]*([A-Z][[:alnum:]_]+) *=/\2/c,class,constant/
--regex-ruby=/(^|;)[ \t]*(has_many|belongs_to|has_one|has_and_belongs_to_many)\(? *:([[:alnum:]_]+)/\3/f,function,association/
--regex-ruby=/(^|;)[ \t]*(named_)?scope\(? *:([[:alnum:]_]+)/\3/f,function,named_scope/
--regex-ruby=/(^|;)[ \t]*expose\(? *:([[:alnum:]_]+)/\2/f,function,exposure/
--regex-ruby=/(^|;)[ \t]*event\(? *:([[:alnum:]_]+)/\2/f,function,aasm_event/
--regex-ruby=/(^|;)[ \t]*event\(? *:([[:alnum:]_]+)/\2!/f,function,aasm_event/
--regex-ruby=/(^|;)[ \t]*event\(? *:([[:alnum:]_]+)/\2?/f,function,aasm_event/
```

By default, vim don't generate tags by default. You should add a file name `.withtags` at your project root to enable it.

After that, you can jump to definition with `ctrl-]`. It provides auto-completion as well. Just use `ctrl-space` to trigger deoplete, it'll show some auto-completion items with `[T]` at the end.

## Switch windows

If you're working with multi windows, you can quickly jump between them with `space-1` -> `space-9` for window 1->9. Or `space-h`, `space-j`, `space-k`, `space-l` to jump right, down, up, left.

## Working with tmux

If you're using tmux like me. There's one more step to quicky jump between tmux panes & vim windows :D. If you don't use tmux, just skip it.

Edit tmux conf

```
$ vi ~/.tmux.conf

is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind -n C-h if-shell "$is_vim" "send-keys C-h"  "select-pane -L"
bind -n C-j if-shell "$is_vim" "send-keys C-j"  "select-pane -D"
bind -n C-k if-shell "$is_vim" "send-keys C-k"  "select-pane -U"
bind -n C-l if-shell "$is_vim" "send-keys C-l"  "select-pane -R"
bind -n C-\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"
```

Now we can use these key mapping to jump around tmux panes & vim windows seamlessly:

```
<ctrl-h> => Left
<ctrl-j> => Down
<ctrl-k> => Up
<ctrl-l> => Right
<ctrl-\> => Previous split
```

## Multiple cursors

```
multi_cursor_next_key: 'ctrl-s'
multi_cursor_prev_key: 'ctrl-p'
multi_cursor_skip_key: 'ctrl-x'
multi_cursor_quit_key: 'esc'
```

## EasyMotion

```
easymotion-s: 'space-f'
easymotion-overwin-f2: 'space-s'
easymotion-sn: 'space-/'
easymotion-next: 'space-n'
easymotion-prev: 'space-N'
```

## Search word under cursor in hole project

Use `K` (shift + k). It'll show the result in Quickfix window at bottom.

## Improve iTerm2 performance:
Settings -> Terminal -> Scrollback Buffer
- `Scrollback lines: 4096`
- Disable `Save lines to scrollback when an app status bar is present`
- Disable `Save lines to scrollback in alternate screen mode`
