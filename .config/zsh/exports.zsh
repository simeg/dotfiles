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

# Shell history is owned by atuin (see .znap-plugins.zsh) — no HISTFILE/
# SAVEHIST here on purpose.

# umask (default macOS value)
umask 022

