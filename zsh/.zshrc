# Export oh-my-zsh folder
export ZSH=$HOME/.oh-my-zsh

# oh-my-zsh stuff
ZSH_THEME="robbyrussell"
# All zsh plugins are installed by default, this is where they are enabled
plugins=(git z zsh-completions zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search docker osx)
source $ZSH/oh-my-zsh.sh

# Use brew's version of vim because it's compiled with +clipboard which means
# I can share clipboard between OS X and vim
alias vim="/usr/local/bin/vim"

alias mv="mv -i -v"
alias cp="cp -i -v"
alias tt="tree"
alias v="vim"
alias d="docker"
alias h="heroku"
alias cat="ccat"

alias dotfiles="pushd ~/repos/dotfiles"
alias vimrc="vim ~/.vimrc"
alias vundle="vim ~/.vim/vundle.vim"
alias zshrc="vim ~/.zshrc ; reload"
alias reload="source ~/.zshrc"
alias gitignore="vim ~/.gitignore"
alias idea="eureka"
alias vm="vim ./Makefile"

alias gcom="git checkout master"
alias gforbm="git fetch origin && git rebase origin/master"
alias gap="git add --patch"

function ss {
  eval $(bh | fzf)
}

export GOPATH="$HOME/repos/go"
export GOBIN="$HOME/repos/go/bin"

# Put yarn on the global path
export PATH="$PATH:`yarn global bin`"
export PATH="$PATH:$GOPATH/bin"

# Enable external plugins
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Make 'workon' command globally available
source /usr/local/bin/virtualenvwrapper.sh

# Bashhub installation
if [ -f ~/.bashhub/bashhub.zsh ]; then
    source ~/.bashhub/bashhub.zsh
fi

