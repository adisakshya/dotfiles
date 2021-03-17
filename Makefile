.DEFAULT_GOAL := help

help :
	@echo "fonts		: Install fonts"
	@echo "bash 		: Setup Bash-it"
	@echo "zsh 		: Setup ZSH and ohmyzsh with required themes and plugins"

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

# Install zsh, ohmyzsh
# and required zsh themes and plugins
zsh:
	sudo apt-get install zsh
	echo 'N' | curl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
	git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
