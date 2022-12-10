#!/usr/bin/env bash

set -e

symlink_file_to_home() {
  ln -sfv "$(pwd)/$1" "$HOME"
}

for dotfile in */.*; do
  # Ignore folders
  if [ -f "$dotfile" ]; then
    symlink_file_to_home "$dotfile"
  fi
done

ln -sv "$(pwd)"/vim "$HOME"/.vim
ln -sv "$(pwd)"/bin "$HOME"/.bin

echo "Creating ~/.config"
mkdir -p "$HOME"/.config
echo "Symlinking starship config"
ln -sv "$(pwd)"/starship.toml "$HOME"/.config/
