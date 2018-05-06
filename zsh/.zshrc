# Load zsh
export ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Load zgen
source "${HOME}/.zgen/zgen.zsh"

if ! zgen saved; then

  zgen oh-my-zsh

  # This order matters
  zgen load zsh-users/zsh-syntax-highlighting
  zgen load zsh-users/zsh-history-substring-search

  zgen load zsh-users/zsh-completions
  zgen load zsh-users/zsh-autosuggestions
  zgen load djui/alias-tips
  zgen load chrissicool/zsh-256color

  zgen oh-my-zsh plugins/git
  zgen oh-my-zsh plugins/brew
  zgen oh-my-zsh plugins/z
  zgen oh-my-zsh plugins/docker
  zgen oh-my-zsh plugins/osx
  zgen oh-my-zsh plugins/sudo
  zgen oh-my-zsh plugins/vi-mode
  zgen oh-my-zsh plugins/colored-man-pages
  zgen oh-my-zsh plugins/command-not-found
  zgen oh-my-zsh plugins/copydir
  zgen oh-my-zsh plugins/copyfile
  zgen oh-my-zsh plugins/cp

  # Automatically run zgen update and zgen selfupdate every 7 days
  zgen load unixorn/autoupdate-zgen

  zgen save
fi

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
alias dir="dirs -v | head -10"
alias ha="history | ack"

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

export PATH="$PATH:`yarn global bin`"
export PATH="$PATH:$GOPATH/bin"

export PATH="$PATH:$HOME/.bin"

# Make 'workon' command globally available
source /usr/local/bin/virtualenvwrapper.sh

# Bashhub installation
if [ -f ~/.bashhub/bashhub.zsh ]; then
    source ~/.bashhub/bashhub.zsh
fi

#ZSH_THEME="robbyrussell"
ZSH_THEME="spaceship"
source "/Users/simon/.oh-my-zsh/custom/themes/spaceship.zsh-theme"

SPACESHIP_BATTERY_SHOW=false
SPACESHIP_PROMPT_SYMBOL=→
SPACESHIP_PROMPT_SEPARATE_LINE=false
SPACESHIP_NODE_SHOW=false
SPACESHIP_PACKAGE_SHOW=false
SPACESHIP_GOLANG_SHOW=false
SPACESHIP_PHP_SHOW=false
SPACESHIP_RUST_SHOW=false

