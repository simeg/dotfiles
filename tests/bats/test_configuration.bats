#!/usr/bin/env bats

# Configuration validation tests migrated from test_dotfiles.sh
# Tests Zsh, modular configs, plugins, starship, neovim, git, and path configuration

load setup_suite

@test "Zsh syntax validation" {
    local zshrc="$HOME/.zshrc"
    
    # In CI environment, test the source file instead of symlink
    if [[ ! -f "$zshrc" ]]; then
        local source_zshrc="$DOTFILES_DIR/.config/zsh/.zshrc"
        
        if [[ -f "$source_zshrc" ]]; then
            echo "Testing source .zshrc (CI environment)" >&3
            run zsh -n "$source_zshrc"
            [ "$status" -eq 0 ]
            return
        else
            echo "No .zshrc found at $zshrc or $source_zshrc" >&3
            return 1
        fi
    fi

    # Test zsh syntax without executing
    run zsh -n "$zshrc"
    [ "$status" -eq 0 ]
}

@test "Modular configs exist" {
    local config_dir="$HOME/.config/zsh"
    local configs=("aliases.zsh" "exports.zsh" "functions.zsh" "misc.zsh" "path.zsh")
    local source_dir="$DOTFILES_DIR/.config/zsh"

    for config in "${configs[@]}"; do
        # Check both installed location and source location
        if [[ -f "$config_dir/$config" ]]; then
            continue  # Found in installed location
        elif [[ -f "$source_dir/$config" ]]; then
            echo "Found $config in source directory (CI environment)" >&3
            continue  # Found in source location
        else
            echo "Missing modular config: $config (checked $config_dir and $source_dir)" >&3
            return 1
        fi
    done
}

@test "Modular configs syntax validation" {
    local config_dir="$HOME/.config/zsh"
    local configs=("aliases.zsh" "exports.zsh" "functions.zsh" "misc.zsh" "path.zsh")
    local source_dir="$DOTFILES_DIR/.config/zsh"

    for config in "${configs[@]}"; do
        local config_file=""
        
        # Find the config file (prefer installed version)
        if [[ -f "$config_dir/$config" ]]; then
            config_file="$config_dir/$config"
        elif [[ -f "$source_dir/$config" ]]; then
            config_file="$source_dir/$config"
            echo "Testing $config from source directory (CI environment)" >&3
        else
            echo "Config file not found: $config" >&3
            return 1
        fi
        
        # Test syntax
        run zsh -n "$config_file"
        [ "$status" -eq 0 ]
    done
}

@test "Private config setup" {
    local private_config="$HOME/.config/zsh/private.zsh"

    # Private config should exist or be mentioned in docs
    if [[ ! -f "$private_config" ]]; then
        echo "Private config not found at $private_config (this is normal for new setups)" >&3
        # Check if it would be sourced correctly if it existed
        run grep -q "private.zsh" "$HOME/.zshrc"
        [ "$status" -eq 0 ]
    else
        # If it exists, test syntax
        run zsh -n "$private_config"
        [ "$status" -eq 0 ]
    fi
}

@test "Essential commands available" {
    local commands=("git" "zsh")

    for cmd in "${commands[@]}"; do
        run command -v "$cmd"
        [ "$status" -eq 0 ]
    done
}

@test "Zsh plugins configuration" {
    # Check if znap is installed
    [ -d "$HOME/.zsh/znap" ]

    # Check if znap plugins file exists
    [ -f "$HOME/.znap-plugins.zsh" ]

    # Test znap plugins file syntax
    run zsh -n "$HOME/.znap-plugins.zsh"
    [ "$status" -eq 0 ]
}

@test "Starship prompt configuration" {
    # Check if starship is installed
    run command -v starship
    [ "$status" -eq 0 ]

    # Check if starship config exists and is readable
    local config_file="$HOME/.config/starship.toml"
    [ -f "$config_file" ]

    # Basic TOML syntax validation (check for basic structure)
    run grep -q '\[' "$config_file"
    [ "$status" -eq 0 ]
}

@test "Neovim configuration" {
    local ideavimrc="$HOME/.ideavimrc"
    local nvim_config="$HOME/.config/nvim"

    # Check if Neovim config directory exists
    [ -d "$nvim_config" ]

    # Check if .ideavimrc exists (for JetBrains IDEs)
    [ -f "$ideavimrc" ]

    # Basic ideavimrc syntax check
    if [[ -f "$ideavimrc" ]]; then
        # Check for basic syntax by looking for vim-specific patterns
        run grep -q "set\|let\|map\|source" "$ideavimrc"
        [ "$status" -eq 0 ]
    fi
}

@test "Git configuration" {
    # Check if git is configured
    run git config --get user.name
    [ "$status" -eq 0 ]

    run git config --get user.email
    [ "$status" -eq 0 ]
}

@test "Homebrew integration" {
    # Only test on macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        run command -v brew
        [ "$status" -eq 0 ]
    else
        skip "Not running on macOS"
    fi
}

@test "PATH configuration" {
    # Check if essential directories are in PATH
    local essential_paths=("$HOME/bin" "/usr/local/bin")

    for path_dir in "${essential_paths[@]}"; do
        if [[ -d "$path_dir" ]] && [[ ":$PATH:" != *":$path_dir:"* ]]; then
            echo "Essential directory not in PATH: $path_dir" >&3
            return 1
        fi
    done
}