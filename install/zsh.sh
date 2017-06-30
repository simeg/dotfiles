#!/bin/sh

set -e

# Installs zsh with plugins using brew.

# Sanity check. Is brew installed on the system? If not - install it
type brew >/dev/null 2>&1 || {
  echo >&2 "Could not find brew. Is it installed?"; exit 1;
}

/usr/local/bin/brew install \
  z \
  zsh \
  zsh-completions \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  jq

