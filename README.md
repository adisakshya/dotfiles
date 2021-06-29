Adisakshya's dotfiles!
## Dependencies
- [Git](https://git-scm.com/downloads)
- [Make](https://en.wikipedia.org/wiki/Make_(software))
    - For Windows - [Using winget](https://winget.run/pkg/GnuWin32/Make)
    - For Linux - ```$ apt-get install build-essential```

## Installation

### Download dotfiles repository

```bash
git clone https://github.com/adisakshya/dotfiles ~/.dotfiles && cd ~/.dotfiles
```

Dotfiles can be installed either using the [Makefile](./Makefile) or the dotbot install-scripts.

The Makefile contain bootstrap scripts helping in installing prerequisites and utilities -
- Source Code Pro Powerline Font
- Oh My Posh
- Scoop (for Windows)
- ZSH, Oh My ZSH and required ZSH plugins (for Linux)

After installing these prerequisites the symlinks are created for the chosen profile using dotbot install-script.

### On Windows

```bash
make windows
```

### On Linux

```bash
make linux
```

### Installing a predefined profile

```bash
$ ./install-profile <profile> [<configs...>]
```
See [meta/profiles/](./meta/profiles) for available profiles

### Installing single configurations

```bash
$ ./install-standalone <configs...>
```
See [meta/configs/](./meta/configs) for available configurations

## Contents

### Profiles
<pre>
meta/profiles
├── <a href="./meta/profiles/linux" title="linux">linux</a>
└── <a href="./meta/profiles/windows" title="windows">windows</a>
</pre>

### Configs
<pre>
meta
├── <a href="./meta/base.yaml" title="base.yaml">base.yaml</a>
└── configs
    ├── <a href="./meta/configs/bash.yaml" title="bash.yaml">bash.yaml</a>
    ├── <a href="./meta/configs/essentials.yaml" title="essentials.yaml">essentials.yaml</a>
    ├── <a href="./meta/configs/oh-my-posh.yaml" title="oh-my-posh.yaml">oh-my-posh.yaml</a>
    ├── <a href="./meta/configs/powershell.yaml" title="powershell.yaml">powershell.yaml</a>
    ├── <a href="./meta/configs/vscode.yaml" title="vscode.yaml">vscode.yaml</a>
    ├── <a href="./meta/configs/windows-terminal.yaml" title="windows-terminal.yaml">windows-terminal.yaml</a>
    └── <a href="./meta/configs/zsh.yaml" title="zsh.yaml">zsh.yaml</a>
</pre>
