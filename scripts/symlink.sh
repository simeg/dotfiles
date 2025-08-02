#!/usr/bin/env bash

safe_ln() {
  local src="$1"
  local dst="$2"
  if [ -L "$dst" ] || [ ! -e "$dst" ]; then
    ln -sfv "$src" "$dst"
  else
    echo "⚠️  Skipping $dst — not a symlink and already exists"
  fi
}

# Symlinks all files in this repo that start with . to $HOME
symlink_file_to_home() {
  safe_ln "$(pwd)/$1" "$HOME"
}

for dotfile in */.*; do
  # Ignore folders
  if [ -f "$dotfile" ]; then
    symlink_file_to_home "$dotfile"
  fi
done

safe_ln "$(pwd)"/nvim "$HOME"/.config
safe_ln "$(pwd)"/nvim/.ideavimrc "$HOME"/.ideavimrc
safe_ln "$(pwd)"/scripts/bin "$HOME"/.bin

echo "Creating ~/.config directories"
mkdir -p "$HOME"/.config/zsh
echo "Setting up starship theme (default: enhanced)"
# Use starship-theme script to set the enhanced theme as default
if [[ -x "$(pwd)/scripts/bin/starship-theme" ]]; then
    "$(pwd)/scripts/bin/starship-theme" set catppuccin
else
    # Fallback: direct symlink if script not available
    safe_ln "$(pwd)"/starship/themes/enhanced.toml "$HOME"/.config/starship.toml
fi
echo "Symlinking zsh modular configs"
safe_ln "$(pwd)"/zsh/exports.zsh "$HOME"/.config/zsh
safe_ln "$(pwd)"/zsh/path.zsh "$HOME"/.config/zsh
safe_ln "$(pwd)"/zsh/aliases.zsh "$HOME"/.config/zsh
safe_ln "$(pwd)"/zsh/functions.zsh "$HOME"/.config/zsh
safe_ln "$(pwd)"/zsh/misc.zsh "$HOME"/.config/zsh

echo "✅ All symlinks set!"
