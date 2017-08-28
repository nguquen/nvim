# 1. Installation

## Install iTerm2, current version is 3.0.14

```
https://www.iterm2.com/downloads.html
```

## Install neovim:

```
$ brew install neovim/neovim/neovim
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
$ pip install neovim
$ pip3 install neovim
```

## Open neovim & check health:

```
$ vi
```

Inside vim, type this command:

```
:CheckHealth
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
:UpdateRemotePlugins
```

## Install powerline fonts:

`vim-airline` use powerline fonts for display some special characters like arrow, install it here:
[https://github.com/powerline/fonts](https://github.com/powerline/fonts). Choose a font that you like and install it for iTerm2.

## Install eslint:

We use `Neomake`, a asynchronous linting and make framework for Neovim/Vim. For javascript files, neomake will call to external linter like `eslint` or `flow`. We will install eslint and all of it's dependencies first.

```
$ sudo npm install -g eslint
```

Install dependencies

```
$ sudo npm install -g babel-eslint babel-plugin-istanbul eslint-config-standard eslint-config-standard-react eslint-plugin-babel eslint-plugin-promise eslint-plugin-react eslint-plugin-standard
```

Checkout a reactjs boilerplate and test eslint:

```
$ git clone https://github.com/davezuko/react-redux-starter-kit.git
$ cd react-redux-starter-kit
$ eslint src
```

`eslint` should exit normally. If not, it will throw some errors about missing some dependencies, you must install the missing dependencies by npm with `-g` option.

## Install flow-bin:

By default Vim will use local flow-bin in `node_modules`, so you don't need to install it globally, just add it as a dependency in your package.json.

## Install Silver Search for use with Ctrl-P:

```
brew install the_silver_searcher
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

## deoplete: auto-completion

Use `ctrl-space` for trigger auto-completion feature. Inside deoplete menu, you can use `j`, `k`, or `tab` to navigate between auto-completion items. `Enter` to select the auto-completion item and exit deoplete menu.

## Neomake

Save current file for trigger the linter. If that file has any errors, it'll show `E: <number>` at the bottom right corner. Then press `space-[` to toggle error detail list.

## Working with flow

There's an official plugin for vim: `vim-flow`. Basically, it provides some features:
- auto-completion
- check type errors
- jump to definition
- display variable type

But it's not good enough, because it's missing asynchonous feature of Neovim. Then i just config vim-flow combine with deoplete (auto-completion) and neomake (check type errors) to maximum the benifit of neovim.

- auto-completion: through `deoplete-flow`, trigger it normally by `ctrl-space` (deprecated)
- check type errors: through neomake, just add `flow` to list of javascript makers. Trigger it on saving file.
- jump to definition: use `ctrl-]`
- display variable type: use `space-d`

### UPDATE
I just replaced `vim-flow`, `deoplete-flow` with `flow-language-server` and `LanguageClient-neovim`. It's better than old solution. Just install `flow-language-server`:
```
npm install -g flow-language-server
```

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

