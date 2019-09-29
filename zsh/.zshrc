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

# Load gruvbox color palette
source ${VIM_PLUGIN_DIR}"/gruvbox/gruvbox_256palette.sh"

# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish
