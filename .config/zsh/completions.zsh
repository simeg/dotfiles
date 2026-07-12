#!/usr/bin/env zsh
########################################
# 🔄 Tab Completions Configuration
# Lazy-loaded completions for better startup performance
########################################

# Note: fpath additions and compinit are handled in .znap-plugins.zsh so
# that fzf-tab loads against a populated fpath. Per-tool lazy loaders below.

# ☸️ kubectl completions (lazy load on first use)
if command -v kubectl &>/dev/null; then
  # Store original kubectl path before aliases override it
  _kubectl_completion_lazy_load() {
    unset -f _kubectl_completion_lazy_load
    source <(command kubectl completion zsh)
  }

  # Hook into kubecolor to load completions on first use
  kubecolor() {
    if typeset -f _kubectl_completion_lazy_load > /dev/null; then
      _kubectl_completion_lazy_load
    fi
    command kubecolor "$@"
  }
fi

# ☁️ Google Cloud SDK (lazy load completions on first use)
# path.zsh.inc is already sourced in path.zsh. Hardcode the Homebrew prefix
# like path.zsh does — `$(brew --prefix)` costs a subshell per startup.
if [[ -f "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc" ]]; then
  gcloud() {
    unset -f gcloud
    source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"
    gcloud "$@"
  }
fi
