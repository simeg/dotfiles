#!/usr/bin/env bash

set -e

# Installs Rust. By installing with rustup it makes it easy to handle multiple
# versions, including non-stable versions. That is not as easy when installing
# via Homebrew.

# Check if rustup is already installed
if command -v rustup >/dev/null 2>&1; then
    echo "Rust/rustup already installed"
    exit 0
fi

echo "Installing Rust via rustup..."

# Check if running in CI environment for non-interactive installation
if [[ "$DOTFILES_CI" == "true" ]] || [[ -n "$CI" ]] || [[ -n "$GITHUB_ACTIONS" ]]; then
    # Non-interactive installation for CI
    curl https://sh.rustup.rs -sSf | sh -s -- -y
else
    # Interactive installation for local development
    curl https://sh.rustup.rs -sSf | sh
fi

