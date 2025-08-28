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

# The next line enables shell command completion for gcloud.
if [ -f '/Users/segersand/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/segersand/google-cloud-sdk/completion.zsh.inc'; fi

