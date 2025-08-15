#!/usr/bin/env bats

# CI-compatible tests migrated from test_ci.sh
# These tests don't require symlinks and work in CI environments

load setup_suite

@test "Essential commands are available" {
    local commands=("git" "zsh")

    for cmd in "${commands[@]}"; do
        run command -v "$cmd"
        [ "$status" -eq 0 ]
    done
}

@test "Zsh configuration files have valid syntax" {
    local zsh_config_dir="$DOTFILES_DIR/.config/zsh"
    local configs=(".zshrc" "aliases.zsh" "exports.zsh" "functions.zsh" "misc.zsh" "path.zsh")

    for config in "${configs[@]}"; do
        local config_file="$zsh_config_dir/$config"
        if [[ -f "$config_file" ]]; then
            echo "Testing syntax of $config_file" >&3
            run zsh -n "$config_file"
            [ "$status" -eq 0 ]
        else
            echo "Config file not found: $config_file" >&3
            return 1
        fi
    done
}

@test "Neovim configuration structure is valid" {
    local nvim_config="$DOTFILES_DIR/.config/nvim"
    
    [ -d "$nvim_config" ]
    [ -f "$nvim_config/init.lua" ]
    
    # Check for required directories
    [ -d "$nvim_config/lua/core" ]
    [ -d "$nvim_config/lua/plugins" ]
    
    # Check that there are Lua files
    local lua_files
    lua_files=$(find "$nvim_config" -name "*.lua" -type f | wc -l)
    [ "$lua_files" -gt 0 ]
}

@test "Git configuration files are valid" {
    local git_dir="$DOTFILES_DIR/git"
    local gitconfig="$git_dir/.gitconfig"
    local gitignore="$git_dir/.gitignore"
    
    # Check if git files exist and are readable
    if [[ -f "$gitconfig" ]]; then
        # Basic syntax check - should be valid config format
        run git config --file "$gitconfig" --list
        [ "$status" -eq 0 ]
    fi
    
    if [[ -f "$gitignore" ]]; then
        # Gitignore should be readable
        [ -r "$gitignore" ]
    fi
}

@test "Starship configuration files are valid" {
    local starship_dir="$DOTFILES_DIR/.config/starship"
    
    if [[ -d "$starship_dir" ]]; then
        # Check theme files for basic TOML syntax
        local toml_files=0
        while IFS= read -r -d '' toml_file; do
            toml_files=$((toml_files + 1))
            # Basic TOML validation - check for proper section format
            run grep -q '\[.*\]' "$toml_file"
            [ "$status" -eq 0 ]
        done < <(find "$starship_dir" -name "*.toml" -type f -print0)
        
        [ "$toml_files" -gt 0 ]
    fi
}

@test "Brewfile is valid" {
    local brewfile="$DOTFILES_DIR/install/Brewfile"
    
    [ -f "$brewfile" ]
    
    # Check for essential packages
    local essential_packages=("git" "zsh" "starship")
    for package in "${essential_packages[@]}"; do
        run grep -q "brew \"$package\"" "$brewfile"
        [ "$status" -eq 0 ]
    done
}

@test "Shell scripts have valid syntax" {
    # Find all shell scripts and check syntax
    while IFS= read -r -d '' script; do
        echo "Checking syntax of $script" >&3
        
        # Skip scripts that might require special environments
        case "$script" in
            */test_*) continue ;;  # Skip test scripts themselves
            */setup.sh) continue ;;  # Setup might require interactive input
        esac
        
        run bash -n "$script"
        [ "$status" -eq 0 ]
    done < <(find "$DOTFILES_DIR/scripts" -name "*.sh" -type f -print0 2>/dev/null || true)
}

@test "No trailing whitespace in configuration files" {
    local issues=0
    
    # Check for trailing whitespace in key config files
    while IFS= read -r -d '' file; do
        if grep -q '[[:space:]]$' "$file"; then
            echo "Trailing whitespace found in: $file" >&3
            issues=$((issues + 1))
        fi
    done < <(find "$DOTFILES_DIR" -type f \( -name "*.zsh" -o -name "*.sh" -o -name "*.toml" -o -name "*.lua" \) -print0)
    
    [ "$issues" -eq 0 ]
}

@test "Required directories exist" {
    local required_dirs=(
        ".config/zsh"
        ".config/nvim"
        ".config/starship"
        "scripts"
        "bin"
        "install"
    )
    
    for dir in "${required_dirs[@]}"; do
        [ -d "$DOTFILES_DIR/$dir" ]
    done
}