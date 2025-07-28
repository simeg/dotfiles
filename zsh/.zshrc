#!/usr/bin/env zsh
########################################
# 🧠 Environment Setup
########################################

# Performance monitoring - track startup
SHELL_STARTUP_START=$(date +%s%N 2>/dev/null || date +%s000000000)

# Load plugin manager znap
source ~/.zsh/znap/znap.zsh

# Load all plugins from external file
source "${HOME}/.znap-plugins.zsh"

# Load modular configuration files (only if they exist)
[[ -f "${HOME}/.config/zsh/exports.zsh" ]] && source "${HOME}/.config/zsh/exports.zsh"
[[ -f "${HOME}/.config/zsh/path.zsh" ]] && source "${HOME}/.config/zsh/path.zsh"
[[ -f "${HOME}/.config/zsh/functions.zsh" ]] && source "${HOME}/.config/zsh/functions.zsh"
[[ -f "${HOME}/.config/zsh/misc.zsh" ]] && source "${HOME}/.config/zsh/misc.zsh"
[[ -f "${HOME}/.config/zsh/private.zsh" ]] && source "${HOME}/.config/zsh/private.zsh"

# Load aliases AFTER plugins to override any conflicting aliases
[[ -f "${HOME}/.config/zsh/aliases.zsh" ]] && source "${HOME}/.config/zsh/aliases.zsh"

fpath=(~/.local/share/zsh/completions $fpath)
autoload -U compinit && compinit


########################################
# 💻 Prompt (fast init)
########################################
eval "$(starship init zsh)"

########################################
# 🌍 Google Cloud
########################################
export GCLOUD_CREDENTIALS="$HOME/.config/gcloud/credentials"

########################################
# 🧠 Claude (Anthropic Vertex)
########################################
export CLAUDE_CODE_USE_VERTEX=1
export ANTHROPIC_SMALL_FAST_MODEL='claude-3-5-haiku@20241022'
export CLOUD_ML_REGION='europe-west1'
export VERTEX_REGION_CLAUDE_4_0_OPUS='europe-west4'
# Moved to private config file

########################################
# ☕ Java
########################################
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

########################################
# 🐍 Python
########################################
export WORKON_HOME="$HOME/.virtualenvs"
export PROJECT_HOME="$HOME/Devel"
export PYENV_ROOT="$HOME/.pyenv"
znap eval pyenv 'eval "$(pyenv init -)"'

########################################
# 📦 SDKMAN
########################################
export SDKMAN_DIR="$HOME/.sdkman"
znap eval sdkman '[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"'

########################################
# 🧭 zoxide (smart cd)
########################################
# Should not be lazy loaded
eval "$(zoxide init zsh)"

########################################
# 📁 Legacy: Remove old shell directory references
########################################
# This section has been moved to modular config files above

########################################
# 🔄 Completions
########################################
#
# kubectl completions
if command -v kubectl &>/dev/null; then
  source <(kubectl completion zsh)
fi

# Google Cloud SDK completions
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

########################################
# ⚡ Quality-of-Life Tweaks
########################################

# Gruvbox terminal palette
source "${VIM_PLUGIN_DIR}/gruvbox/gruvbox_256palette.sh"

# Speed up Git prompt by ignoring untracked files
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Faster pasting with autosuggestions
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic
}
pastefinish() {
  zle -N self-insert "$OLD_SELF_INSERT"
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# Something adds this for me, just let it be
export PATH=/opt/spotify-devex/bin:$PATH

# Performance optimizations
# Enable profiling (uncomment for debugging)
# zmodload zsh/zprof

# Skip global compinit for faster startup
skip_global_compinit=1

# Let znap compile stuff so it's faster to load
znap compile ~/.zshrc ~/.znap-plugins.zsh || true

# Profiling output (uncomment for debugging)
# zprof

########################################
# 📊 Performance & Usage Analytics
########################################

# Load performance monitoring
if [[ -f ~/.config/dotfiles/perf-monitor.sh ]]; then
    source ~/.config/dotfiles/perf-monitor.sh
    # Track startup completion
    track_shell_startup "$SHELL_STARTUP_START" "complete"
fi

# Package Usage Analytics (added by analyze-package-usage.sh)
if [[ -f ~/.config/dotfiles/usage-analytics.sh ]]; then
    source ~/.config/dotfiles/usage-analytics.sh
fi

# Override any plugin aliases - ensure neovim is used
# Use functions instead of aliases to prevent override
vim() { nvim "$@"; }
v() { nvim "$@"; }
vi() { nvim "$@"; }

