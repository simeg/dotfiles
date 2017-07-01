#!/bin/sh

set -e

# Installs zsh with plugins using brew, assumes brew is installed

/usr/local/bin/brew install \
  z \
  zsh \
  zsh-completions \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  jq

