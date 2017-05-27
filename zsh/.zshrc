# Export oh-my-zsh folder
export ZSH=$HOME/.oh-my-zsh

# oh-my-zsh stuff
ZSH_THEME="robbyrussell"
# All zsh plugins are installed by default, this is where they are enabled
plugins=(git z zsh-completions zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

alias tt="tree"
alias v="vim"
alias vimrc="vim ~/.vimrc"
alias zshrc="vim ~/.zshrc"
alias d="docker"
alias new-idea="vim /Users/simon/repos/ideas/README.md"

# Put yarn on the global path
export PATH="$PATH:`yarn global bin`"

# Enable external plugins
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Has something to do with enabling shell integration in iTerm,
# causing some conflict with zsh.
# http://stackoverflow.com/questions/36518973/iterm2-shell-integration-and-oh-my-zsh-conflicts
# test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

