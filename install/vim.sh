#!/bin/bash
#
# Creates necessary folders for vim if they
# do not already exist.

# Creates folder if it does not already exist 
function mkdir_if_not_exist {
  if [ ! -d $1 ]; then
    mkdir -v $1
  else
    echo "$1 already exist, will not create a new one";
  fi
}

# This has to be hard coded for some reason,
# does not work using ~/
HOME="/Users/simon"

SWAP_DIR="$HOME/.vim/swaps"
BACKUP_DIR="$HOME/.vim/backups"
UNDO_DIR="$HOME/.vim/undo"

mkdir_if_not_exist $SWAP_DIR
mkdir_if_not_exist $BACKUP_DIR
mkdir_if_not_exist $UNDO_DIR

echo "Vim setup script complete"
