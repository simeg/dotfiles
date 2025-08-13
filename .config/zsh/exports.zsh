#!/usr/bin/env zsh

########################################
# 🧠 General Environment
########################################

export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

########################################
# ⚙️ Zsh & Shell Behavior
########################################

# Enable completion dots when waiting
export COMPLETION_WAITING_DOTS=true

# Skip global compinit to speed up shell startup
export skip_global_compinit=1

# Shell history size
export SAVEHIST=10000000

# umask (default macOS value)
umask 022

