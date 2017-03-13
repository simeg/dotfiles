#!/bin/sh
#
# Installs zsh with plugins using brew.

# Sanity check. Is brew installed on the system?
type brew >/dev/null 2>&1 || {
  echo >&2 "Could not find brew. Is it installed?"; exit 1;
}

brew install \
  z \
  zsh \
  zsh-completions \
  zsh-autosuggestions \
  zsh-syntax-highlighting

