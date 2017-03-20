# Installation

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
```

## Install powerline fonts:

`vim-airline` use powerline fonts for display some special characters like arrow, install it here:
[https://github.com/powerline/fonts](https://github.com/powerline/fonts). Choose a font that you like and install it for iTerm2.

## Install eslint:

We use `Neomake`, a asynchronous linting and make framework for Neovim/Vim. For javascript files, neomake will call to external linter like `eslint` or `flow`. We will install eslint and all of dependencies first.

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

# Key mappings

...
