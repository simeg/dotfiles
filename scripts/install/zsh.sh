#!/usr/bin/env bash

set -e

# Installs zsh with plugins using brew, assumes brew is installed

# Support both Intel and Apple Silicon Macs
if command -v brew >/dev/null 2>&1; then
    brew install zsh
    # Additional plugins can be uncommented if needed:
    # brew install zsh-completions
    # brew install zsh-autosuggestions  
    # brew install zsh-syntax-highlighting
else
    echo "Error: Homebrew not found. Please install Homebrew first."
    exit 1
fi

# Install znap, plugin manager
echo "Installing znap..."
git clone https://github.com/marlonrichert/zsh-snap.git "${HOME}/.znap"
echo "Done installing znap!"

