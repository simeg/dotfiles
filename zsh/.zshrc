# Export oh-my-zsh folder
export ZSH=$HOME/.oh-my-zsh

# oh-my-zsh stuff
ZSH_THEME="robbyrussell"
# All zsh plugins are installed by default, this is where they are enabled
plugins=(git z zsh-completions zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)
source $ZSH/oh-my-zsh.sh

alias mv="mv -i -v"
alias cp="cp -i -v"
alias tt="tree"
alias v="vim"
alias d="docker"

alias dotfiles="pushd ~/repos/dotfiles"
alias reload="source ~/.zshrc"
alias vimrc="vim ~/.vimrc"
alias vundle="vim ~/.vim/vundle.vim"
alias zshrc="vim ~/.zshrc ; reload"
alias gitignore="vim ~/.gitignore"
alias idea="vim ~/repos/ideas/README.md"

alias gcom="git checkout master"
alias gforbm="git fetch origin && git rebase origin/master"

# Put yarn on the global path
export PATH="$PATH:`yarn global bin`"

# Enable external plugins
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Bashhub installation
if [ -f ~/.bashhub/bashhub.zsh ]; then
    source ~/.bashhub/bashhub.zsh
fi

