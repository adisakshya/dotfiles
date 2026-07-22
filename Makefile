# Default target
.DEFAULT_GOAL := help

# Pinned upstream revisions. See README.md before updating these values.
OH_MY_POSH_VERSION := 29.34.0
OH_MY_POSH_LINUX_SHA256 := 90f33e71f181e959f1511d03f05ee0843c5eab4d7799e2d479a13c3fdd5b7c44
OH_MY_ZSH_COMMIT := 59a9740721b734835812121322d6fe4827b0853a
ZSH_SYNTAX_HIGHLIGHTING_COMMIT := 1d85c692615a25fe2293bdd44b34c217d5d2bf04
ZSH_AUTOSUGGESTIONS_COMMIT := 85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5

# PHONY
.PHONY: windows linux

help :
	@echo "win \t: Bootstrap and install dotfiles for Windows"
	@echo "lin\t: Bootstrap and install dotfiles for Linux"

bootstrap-windows:
	@echo "-> Installing Powerline font Source Code Pro - https://github.com/powerline/fonts"
	powershell common/fonts/prerequisite.ps1
	powershell common/fonts/install.ps1
	@echo "-> Installing pinned oh-my-posh"
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install-windows-tools.ps1

windows: bootstrap-windows
	./install-profile windows

bootstrap-linux:
	@echo "Install Powerline font - Source Code Pro - https://github.com/powerline/fonts"
	sh common/fonts/install.sh
	@echo "-> Installing oh-my-posh $(OH_MY_POSH_VERSION) - https://ohmyposh.dev"
	scripts/download-verified \
		https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v$(OH_MY_POSH_VERSION)/posh-linux-amd64 \
		$(OH_MY_POSH_LINUX_SHA256) /tmp/oh-my-posh
	sudo install -m 0755 /tmp/oh-my-posh /usr/local/bin/oh-my-posh
	rm -f /tmp/oh-my-posh
	@echo "Installing zsh and pinned oh-my-zsh plugins - https://ohmyz.sh"
	sudo apt-get update
	sudo apt-get install zsh
	git clone https://github.com/ohmyzsh/ohmyzsh.git "${HOME}/.oh-my-zsh"
	git -C "${HOME}/.oh-my-zsh" checkout --detach $(OH_MY_ZSH_COMMIT)
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
	git -C "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" checkout --detach $(ZSH_SYNTAX_HIGHLIGHTING_COMMIT)
	git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
	git -C "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" checkout --detach $(ZSH_AUTOSUGGESTIONS_COMMIT)

linux: bootstrap-linux
	./install-profile linux
