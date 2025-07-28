#!/usr/bin/env bash

# Installs brew

set -e

echo "Installing brew.."
# Check if Homebrew is already installed
if command -v brew >/dev/null 2>&1; then
    echo "Homebrew already installed, skipping..."
    exit 0
fi

# Use the official installation script
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
