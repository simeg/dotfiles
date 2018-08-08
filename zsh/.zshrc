PURE_NODE_DISABLED=1

# Load gruvbox color palette
source "$HOME/.vim/bundle/gruvbox/gruvbox_256palette.sh"

# Load oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
source "${ZSH}/oh-my-zsh.sh"

# Load zgen
source "${HOME}/.zgen/zgen.zsh"
# Load zgen plugins
source "${HOME}/.zgen-plugins"

# Load everything from the shell folder
if [ -d "${HOME}/repos/dotfiles/shell" ]; then
  for FILE in ${HOME}/repos/dotfiles/shell/.*; do
    source $(printf %s.%s "${HOME}/repos/dotfiles/shell/" "$(echo ${FILE} | cut -d. -f2)")
  done
fi
