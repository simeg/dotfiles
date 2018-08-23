#!/bin/bash

set -e

# Creates necessary folders for vim if they
# do not already exist.

# Install vim, assumes brew is installed
/usr/local/bin/brew install vim

# Creates folder if it does not already exist
function mkdir_if_not_exist {
  if [ ! -d "$1" ]; then
    mkdir -v -p "$1"
  else
    echo "$1 already exist, will not create a new one";
  fi
}

# This has to be hard coded for some reason,
# does not work using ~/
HOME="~"

SWAP_DIR="$HOME/.vim/swaps"
BACKUP_DIR="$HOME/.vim/backups"
UNDO_DIR="$HOME/.vim/undo"

mkdir_if_not_exist $SWAP_DIR
mkdir_if_not_exist $BACKUP_DIR
mkdir_if_not_exist $UNDO_DIR

# Install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install plugins
vim +PlugInstall +qall

echo "Vim setup completed!"
