.DEFAULT_GOAL := help

help :
	@echo "fonts		: Install fonts"
	@echo "bash 		: Setup Bash-it with completions and plugins"
	@echo "zsh 		: Setup ZSH"
	@echo "ohmyzsh 	: Install Ohmyzsh with zsh themes and plugins"

# Checks
git-exists: ; @which git > /dev/null
zsh-exists: ; @which zsh > /dev/null

.PHONY: fonts bash zsh ohmyzsh

# Install required fonts
fonts: git-exists
	# git clone https://github.com/powerline/fonts.git
	# .\install.ps1
	echo "Installing fonts..."

# Install Bash-it and 
# and required completions and plugins
bash: git-exists
	git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
	echo 'N' | ~/.bash_it/install.sh
	bash-it enable completion git npm makefile docker docker-compose docker-machine
	bash-it enable plugin docker docker-compose docker-machine git

# Install zsh
zsh:
	sudo apt-get install zsh

# Install ohmyzsh
# and required zsh themes and plugins
ohmyzsh: zsh-exists
	curl -o ohmyzsh.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
	chmod +x ohmyzsh.sh
	echo 'N' | ./ohmyzsh.sh
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
	git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
