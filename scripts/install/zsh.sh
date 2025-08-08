#!/usr/bin/env bash

set -e

# Installs zsh with plugins using brew, assumes brew is installed

# Support both Intel and Apple Silicon Macs
if command -v brew >/dev/null 2>&1; then
    brew install zsh
else
    echo "Error: Homebrew not found. Please install Homebrew first."
    exit 1
fi

# Install znap, plugin manager
echo "Installing znap..."
mkdir -p "${HOME}/.zsh"
if [[ ! -d "${HOME}/.zsh/znap" ]]; then
    git clone https://github.com/marlonrichert/zsh-snap.git "${HOME}/.zsh/znap"
    echo "Done installing znap!"
else
    echo "znap already installed"
fi

