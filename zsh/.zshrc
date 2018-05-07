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
  zgen oh-my-zsh plugins/z
  zgen oh-my-zsh plugins/osx
  zgen oh-my-zsh plugins/colored-man-pages
  zgen oh-my-zsh plugins/copydir
  zgen oh-my-zsh plugins/copyfile
  zgen oh-my-zsh plugins/cp

  # zgen load denysdovhan/spaceship-prompt spaceship
  zgen load mafredri/zsh-async
  zgen load marszall87/lambda-pure

  # Automatically run zgen update and zgen selfupdate every 7 days
  zgen load unixorn/autoupdate-zgen

  zgen save
fi

# Make 'workon' command globally available
source /usr/local/bin/virtualenvwrapper.sh

# Bashhub installation
if [ -f ~/.bashhub/bashhub.zsh ]; then
  source ~/.bashhub/bashhub.zsh
fi

# SPACESHIP_BATTERY_SHOW=false
# SPACESHIP_CHAR_SYMBOL="❯ "
# SPACESHIP_PROMPT_SEPARATE_LINE=true
# SPACESHIP_EXEC_TIME_PREFIX="("
# SPACESHIP_EXEC_TIME_SUFFIX=")"

# SPACESHIP_NODE_SHOW=false
# SPACESHIP_PACKAGE_SHOW=false
# SPACESHIP_GOLANG_SHOW=false
# SPACESHIP_PHP_SHOW=false
# SPACESHIP_RUST_SHOW=false

source "${HOME}/.alias"
source "${HOME}/.functions"
source "${HOME}/.path"
#source "${HOME}/.symlinks"

