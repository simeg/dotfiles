#!/usr/bin/env bash

set -e

# Installs zsh with plugins using brew, assumes brew is installed

/usr/local/bin/brew install \
  z \
  zsh \
  zsh-completions \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  jq

# Install zgen, plugin manager
git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"

