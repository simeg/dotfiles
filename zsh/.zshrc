export ZSH=$HOME/.oh-my-zsh

# Oh My Zsh
ZSH_THEME="robbyrussell" # Currently using some mix of zsh theme and iTerm theme
plugins=(git up_and_back zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# Aliases
alias h='heroku'
alias del='rmtrash' # TODO: Handle dependency 'rmtrash'

# Removing duplicates in $PATH
# typeset -U PATH

# Put yarn on the global path
export PATH="$PATH:`yarn global bin`"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

