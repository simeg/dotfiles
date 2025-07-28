#!/usr/bin/env bash

set -e

# Symlinks all files in this repo that start with . to $HOME

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
ln -sv "$(pwd)"/nvim "$HOME"/.config/nvim
ln -sv "$(pwd)"/scripts/bin "$HOME"/.bin

echo "Creating ~/.config directories"
mkdir -p "$HOME"/.config/zsh
echo "Setting up starship theme (default: enhanced)"
# Use starship-theme script to set the enhanced theme as default
if [[ -x "$(pwd)/scripts/bin/starship-theme" ]]; then
    "$(pwd)/scripts/bin/starship-theme" set enhanced
else
    # Fallback: direct symlink if script not available
    ln -sv "$(pwd)"/starship/themes/enhanced.toml "$HOME"/.config/starship.toml
fi
echo "Symlinking zsh modular configs"
ln -sv "$(pwd)"/zsh/exports.zsh "$HOME"/.config/zsh/
ln -sv "$(pwd)"/zsh/path.zsh "$HOME"/.config/zsh/
ln -sv "$(pwd)"/zsh/aliases.zsh "$HOME"/.config/zsh/
ln -sv "$(pwd)"/zsh/functions.zsh "$HOME"/.config/zsh/
ln -sv "$(pwd)"/zsh/misc.zsh "$HOME"/.config/zsh/
