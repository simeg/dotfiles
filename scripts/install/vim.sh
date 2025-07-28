#!/usr/bin/env bash

set -e

echo "Starting vim setup..."

# Creates necessary folders for vim if they do not already exist.

# Install vim, assumes brew is installed
# Support both Intel and Apple Silicon Macs
if command -v brew >/dev/null 2>&1; then
    brew install vim
else
    echo "Error: Homebrew not found. Please install Homebrew first."
    exit 1
fi

# Creates folder if it does not already exist
function mkdir_if_not_exist {
  if [ ! -d "$1" ]; then
    mkdir -v -p "$1"
  else
    echo "$1 already exist, doing nothing";
  fi
}

# HOME variable should already be set by the shell
# No need to reassign it

SWAP_DIR="$HOME/.vim/swaps"
BACKUP_DIR="$HOME/.vim/backups"
UNDO_DIR="$HOME/.vim/undo"

mkdir_if_not_exist "$SWAP_DIR"
mkdir_if_not_exist "$BACKUP_DIR"
mkdir_if_not_exist "$UNDO_DIR"

# Install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install plugins
vim +PlugInstall +qall

# Symlink .ideavimrc to $HOME
ln -s "$(pwd)/vim/.ideavimrc" "$HOME/.ideavimrc"

echo "Vim setup completed!"
