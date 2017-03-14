# Export oh-my-zsh folder
export ZSH=$HOME/.oh-my-zsh

# oh-my-zsh stuff
ZSH_THEME="robbyrussell"
# All zsh plugins are installed by default, this is where they are enabled
plugins=(git z zsh-completions zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Aliases
alias tt="tree"

# Put yarn on the global path
export PATH="$PATH:`yarn global bin`"

# Enable external plugins here
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Has something to do with enabling shell integration in iTerm,
# causing some conflict with zsh.
# http://stackoverflow.com/questions/36518973/iterm2-shell-integration-and-oh-my-zsh-conflicts
# test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

