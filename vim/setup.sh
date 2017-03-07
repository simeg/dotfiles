#!/bin/bash

# This has to be hard coded for some reason,
# does not work using ~/
HOME="/Users/simon"

SWAP_DIR="$HOME/.vim/swaps"
BACKUP_DIR="$HOME/.vim/backups"
UNDO_DIR="$HOME/.vim/undo"

# Checks for vim folders and creates them if they
# do not exist
if [ ! -d "$SWAP_DIR" ] ; then
  echo "Creating ~/.vim/swaps"
  mkdir ~/.vim/swaps
fi

if [ ! -d "$BACKUP_DIR" ] ; then
  echo "Creating ~/.vim/backups"
  mkdir ~/.vim/backups
fi

if [ ! -d "$UNDO_DIR" ] ; then
  echo "Creating ~/.vim/undo"
  mkdir ~/.vim/undo
fi

echo "Setup script complete"
