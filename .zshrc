export ZSH=/Users/Simon/.oh-my-zsh

ZSH_THEME="robbyrussell" # Currently using some mix of zsh theme and iTerm theme
plugins=(git up_and_back)

source $(brew --prefix nvm)/nvm.sh
source $ZSH/oh-my-zsh.sh

# Aliases
alias h='heroku'
alias del='rmtrash' # TODO: Handle dependency 'rmtrash'

# Removing duplicates in $PATH
# typeset -U PATH

