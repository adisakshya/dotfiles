# Default target
.DEFAULT_GOAL := help

# Targets

help :
	@echo "win 	: Bootstrap and install dotfiles for Windows"
	@echo "lin	: Bootstrap and install dotfiles for Linux"

# Windows

bootstrap-windows:
	@echo "-> Installing Powerline font Source Code Pro - https://github.com/powerline/fonts"
	powershell common/fonts/prerequisite.ps1
	powershell common/fonts/install.ps1
	@echo "-> Installing Scoop - https://github.com/lukesampson/scoop"
	powershell 'iwr -useb get.scoop.sh | iex'
	@echo "-> Installing oh-my-posh - https://ohmyposh.dev"
	powershell "scoop install 'https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json'"

win: bootstrap-windows
	./install-profile windows

# Linux

bootstrap-linux:
	@echo "Install Powerline font - Source Code Pro - https://github.com/powerline/fonts"
	sh common/fonts/install.sh
	@echo "-> Installing oh-my-posh - https://ohmyposh.dev"
	sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
	sudo chmod +x /usr/local/bin/oh-my-posh
	@echo "Installing zsh and ohmyzsh - https://ohmyz.sh"
	sudo apt-get update
	sudo apt-get install zsh
	@echo 'N' | curl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
	git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

lin: bootstrap-linux
	./install-profile linux
