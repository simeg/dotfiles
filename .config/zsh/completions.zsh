#!/usr/bin/env zsh
########################################
# 🔄 Tab Completions Configuration
# Lazy-loaded completions for better startup performance
########################################

# Add custom completions to fpath (consolidate to avoid duplicate compinit)
fpath=(~/.local/share/zsh/completions ~/.config/zsh/completions $fpath)

# Add completions for git-x
if [[ -d ~/.local/share/zsh/site-functions ]]; then
  fpath=(~/.local/share/zsh/site-functions $fpath)
fi

# Single compinit call after all fpath modifications
autoload -U compinit && compinit

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
if [[ -f "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc" ]]; then
  source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
  
  # Lazy load completions
  gcloud() {
    unset -f gcloud
    source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
    gcloud "$@"
  }
fi