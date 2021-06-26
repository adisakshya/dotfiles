# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME="gozilla" # Disabled theme

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

# Language environment
export LANG=en_US.UTF-8

# Alias definitions
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# Exports
if [ -f ~/.exports ]; then
    source ~/.exports
fi

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Docker in WSL
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
    export DOCKER_HOST='tcp://192.168.99.100:2376'
    export DOCKER_TLS_VERIFY=1
    export DOCKER_CERT_PATH=/mnt/c/Users/USERNAME/.docker/machine/machines/default
    export DOCKER_MACHINE_NAME=default
fi

# Set oh-my-posh prompt
eval "$(oh-my-posh --init --shell zsh --config ~/adisakshya.yaml)"

source $ZSH/oh-my-zsh.sh
