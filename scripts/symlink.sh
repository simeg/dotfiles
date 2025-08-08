#!/usr/bin/env bash

# New streamlined symlink script for reorganized dotfiles structure
# This works with the new .config/ organization

safe_ln() {
  local src="$1"
  local dst="$2"

  # If destination is a symlink, remove it first to avoid nested symlinks
  if [ -L "$dst" ]; then
    rm "$dst"
  fi

  # Create symlink if destination doesn't exist or was just removed
  if [ ! -e "$dst" ]; then
    ln -sfv "$src" "$dst"
  else
    echo "⚠️  Skipping $dst — not a symlink and already exists"
  fi
}

# Function to symlink directory contents
symlink_dir_contents() {
  local src_dir="$1"
  local dst_dir="$2"
  local description="$3"
  
  if [[ ! -d "$src_dir" ]]; then
    echo "⚠️  Source directory $src_dir doesn't exist, skipping $description"
    return
  fi
  
  echo "Setting up $description"
  mkdir -p "$dst_dir"
  
  for item in "$src_dir"/*; do
    if [[ -e "$item" ]]; then
      local item_name
      item_name="$(basename "$item")"
      safe_ln "$item" "$dst_dir/$item_name"
    fi
  done
}

echo "🔗 Creating symbolic links with new structure..."

# Symlinks all files in git/ that start with . to $HOME
echo "Setting up Git configuration"
for dotfile in git/.*; do
  # Ignore . and .. and directories
  if [[ -f "$dotfile" && "$(basename "$dotfile")" != "." && "$(basename "$dotfile")" != ".." ]]; then
    safe_ln "$(pwd)/$dotfile" "$HOME/$(basename "$dotfile")"
  fi
done

# Symlink entire .config structure
echo "Setting up .config directory structure"
mkdir -p "$HOME/.config"

# Symlink .config items (but handle zsh specially)
for config_item in .config/*; do
  if [[ -e "$config_item" ]]; then
    item_name="$(basename "$config_item")"
    
    # Special handling for zsh directory - symlink individual files
    if [[ "$item_name" == "zsh" ]]; then
      echo "Setting up zsh configuration files"
      mkdir -p "$HOME/.config/zsh"
      for zsh_file in .config/zsh/*; do
        if [[ -f "$zsh_file" ]]; then
          zsh_filename="$(basename "$zsh_file")"
          safe_ln "$(pwd)/$zsh_file" "$HOME/.config/zsh/$zsh_filename"
        elif [[ -d "$zsh_file" && "$(basename "$zsh_file")" == "completions" ]]; then
          # Handle completions directory
          safe_ln "$(pwd)/$zsh_file" "$HOME/.config/zsh/completions"
        fi
      done
    else
      # Regular symlink for non-zsh directories
      safe_ln "$(pwd)/$config_item" "$HOME/.config/$item_name"
    fi
  fi
done

# Special handling for starship config
echo "Setting up starship theme (default: catppuccin)"
if [[ -x "$(pwd)/bin/starship-theme" ]]; then
    "$(pwd)/bin/starship-theme" set catppuccin
elif [[ -f "$(pwd)/.config/starship/themes/catppuccin.toml" ]]; then
    # Fallback: direct symlink if script not available  
    safe_ln "$(pwd)/.config/starship/themes/catppuccin.toml" "$HOME/.config/starship.toml"
fi

# Symlink bin directory to ~/.bin
echo "Setting up bin directory"
safe_ln "$(pwd)/bin" "$HOME/.bin"

# Handle special files that don't follow the pattern
echo "Setting up special configuration files"

# zshrc (goes to home directory)
if [[ -f ".config/zsh/.zshrc" ]]; then
  safe_ln "$(pwd)/.config/zsh/.zshrc" "$HOME/.zshrc"
fi

# znap plugins file (goes to home directory)
if [[ -f ".config/zsh/.znap-plugins.zsh" ]]; then
  safe_ln "$(pwd)/.config/zsh/.znap-plugins.zsh" "$HOME/.znap-plugins.zsh"
fi

# ideavimrc (goes to home directory) 
if [[ -f ".config/nvim/.ideavimrc" ]]; then
  safe_ln "$(pwd)/.config/nvim/.ideavimrc" "$HOME/.ideavimrc"
fi

# Git configuration files
if [[ -f "git/.gitconfig" ]]; then
  safe_ln "$(pwd)/git/.gitconfig" "$HOME/.gitconfig"
fi

if [[ -f "git/.gitignore" ]]; then
  safe_ln "$(pwd)/git/.gitignore" "$HOME/.gitignore"
fi

echo "✅ All symlinks set with new structure!"
echo ""
echo "📁 Structure summary:"
echo "  ~/.config/nvim       ← .config/nvim"
echo "  ~/.config/starship   ← .config/starship" 
echo "  ~/.config/atuin      ← .config/atuin"
echo "  ~/.config/zsh        ← .config/zsh"
echo "  ~/.bin               ← bin"
echo "  ~/.gitconfig         ← git/.gitconfig"
echo "  ~/.gitignore         ← git/.gitignore"
echo ""
