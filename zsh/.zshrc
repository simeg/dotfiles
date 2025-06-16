# Enable for debugging slow session startup
# zmodload zsh/zprof

autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

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

# Enable bash-completion
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

export GCLOUD_CREDENTIALS=/Users/segersand/.config/gcloud/credentials

export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# Auto-completion for kubectl
if [ /usr/local/bin/kubectl ]; then source <(kubectl completion zsh); fi

# The next line updates PATH for the Google Cloud SDK.
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

# if [ -f '/Users/segersand/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/segersand/google-cloud-sdk/path.zsh.inc'; fi

# # The next line enables shell command completion for gcloud.
# if [ -f '/Users/segersand/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/segersand/google-cloud-sdk/completion.zsh.inc'; fi

export PATH="/usr/local/opt/python@3.7/bin:$PATH"

export PATH="/Users/segersand/.gem/ruby/2.7.0/bin:$PATH"
export PATH="/Users/segersand/.gem/ruby/3.1.0/bin:$PATH"

export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
#source /usr/local/bin/virtualenvwrapper.sh

eval "$(starship init zsh)"

# Enable for debugging slow session startup
# zprof

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
eval "$(pyenv init -)"

export JAVA_HOME=$(/usr/libexec/java_home -v 17)

DISABLE_UNTRACKED_FILES_DIRTY="true"

# Created by `pipx` on 2023-01-26 14:07:12
export PATH="$PATH:/Users/segersand/.local/bin"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export PATH=/opt/spotify-devex/bin:$PATH
