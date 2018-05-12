# Load oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
source "${ZSH}/oh-my-zsh.sh"

# Load zgen
source "${HOME}/.zgen/zgen.zsh"
# Load zgen plugins
source "${HOME}/.zgen-plugins"

# Load everything else
source "${HOME}/.alias"
source "${HOME}/.functions"
source "${HOME}/.path"
source "${HOME}/.other"
source "${HOME}/.theme"
source "${HOME}/.env"
source "${HOME}/.prompt"
#source "${HOME}/.symlinks"

# iTerm2 Shell Integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
