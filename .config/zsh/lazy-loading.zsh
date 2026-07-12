#!/usr/bin/env zsh
########################################
# 🚀 Lazy Loading Configuration
# Defers initialization of slow tools until first use
########################################

# Currently empty by design — former lazy loaders were retired:
# - pyenv: replaced by mise (activated in .zshrc)
# - sdkman: eagerly initialized in .zshrc so JAVA_HOME is set correctly;
#   lazy wrappers here shadowed real binaries and re-sourced sdkman-init
# - atuin: loaded via znap in .znap-plugins.zsh (must load early)
# - kubectl/gcloud completions: lazy-loaded in completions.zsh
