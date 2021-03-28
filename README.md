# dotfiles

## Table of Contents
<!-- TOC GFM -->

- [Dependencies](#dependencies)
- [Installation](#installation)
    - [For installing a predefined profile:](#for-installing-a-predefined-profile)
    - [For installing single configurations:](#for-installing-single-configurations)
- [Contents](#contents)
    - [Profiles](#profiles)
    - [Configs](#configs)

<!-- /TOC -->

## Dependencies
- git

## Installation

```bash
$ git clone https://github.com/adisakshya/dotfiles ~/.dotfiles
$ cd ~/.dotfiles
```

### For installing a predefined profile:

```bash
$ ./install-profile <profile> [<configs...>]
```
See [meta/profiles/](./meta/profiles) for available profiles

### For installing single configurations:

```bash
$ ./install-standalone <configs...>
```
See [meta/configs/](./meta/configs) for available configurations

## Contents

### Profiles
<pre>
meta/profiles
├── <a href="./meta/profiles/unix" title="unix">unix</a>
└── <a href="./meta/profiles/windows" title="windows">windows</a>
</pre>

### Configs
<pre>
meta
├── <a href="./meta/base.yaml" title="base.yaml">base.yaml</a>
└── configs
    ├── <a href="./meta/configs/bash.yaml" title="bash.yaml">bash.yaml</a>
    └── <a href="./meta/configs/zsh.yaml" title="zsh.yaml">zsh.yaml</a>
</pre>
