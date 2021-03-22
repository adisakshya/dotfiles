# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

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

# Path to the bash-it configuration
export BASH_IT="$HOME/.bash_it"

# Lock and Load a custom theme file
# location /.bash_it/themes/
# export BASH_IT_THEME='robbyrussell' # Disabled bash-it theme

# Your place for hosting Git repos. I use this for private repos
export GIT_HOSTING='git@git.domain.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice
export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
export TODO="t"

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=false

# Enable display of last command duration
export BASH_IT_COMMAND_DURATION=true
export COMMAND_DURATION_MIN_SECONDS=1


# (Advanced): Uncomment this to make Bash-it reload itself automatically
# after enabling or disabling aliases, plugins, and completions.
# export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Load Bash It
source "$BASH_IT"/bash_it.sh

# Bash prompt
if [[ "$(uname)" == "MINGW"* ]]; then
    # Windows
    __PS1_BEFORE='\n'
    __PS1_LOCATION='\033[1;36m\W'
    __PS1_GIT_BRANCH='\033[1;32m`__git_ps1`'
    __PS1_AFTER='\033[1;37m $ '
    export PROMPT_COMMAND='PS1="${__PS1_BEFORE}${__PS1_LOCATION}${__PS1_GIT_BRANCH}${__PS1_AFTER}"'
elif [[ "$(uname)" == "Linux" ]]; then
    # Linux
    source ~/.bash_prompt
fi
