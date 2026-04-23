#!/usr/bin/env bash

########################################
# 🛠️ Shell Options
########################################

# Enable changing directories by typing the path directly (without 'cd')
# This allows commands like '../some-dir' to work
setopt AUTO_CD

########################################
# 🌍 External Tool Completions
########################################

# gcloud shell completion (installed via Homebrew cask)
[[ -f "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc" ]] && source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"

