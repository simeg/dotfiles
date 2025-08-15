#!/usr/bin/env bats

# Advanced configuration validation tests migrated from test_advanced.sh
# Tests comprehensive configuration validation

load setup_suite

@test "Zsh configuration validation" {
    local zsh_config_dir="$DOTFILES_DIR/.config/zsh"
    local required_files=(".zshrc" "aliases.zsh" "exports.zsh" "functions.zsh" "misc.zsh" "path.zsh")

    # Check all required files exist
    for file in "${required_files[@]}"; do
        [ -f "$zsh_config_dir/$file" ]
    done

    # Validate .zshrc sources all modules
    local zshrc="$zsh_config_dir/.zshrc"
    if [[ -f "$zshrc" ]]; then
        for module in "aliases" "exports" "functions" "misc" "path"; do
            run grep -q "$module.zsh" "$zshrc"
            [ "$status" -eq 0 ]
        done
    fi

    # Check for dangerous command redefinitions (unsafe patterns)
    local dangerous_patterns=("alias rm=" "alias chmod=" "alias chown=" "alias sudo=")
    for pattern in "${dangerous_patterns[@]}"; do
        if grep -q "$pattern" "$zsh_config_dir/aliases.zsh" 2>/dev/null; then
            # Exclude safe patterns (with -i interactive flag or similar safety measures)
            run bash -c "grep -E '$pattern.*(-i|--interactive)' '$zsh_config_dir/aliases.zsh'"
            [ "$status" -eq 0 ]
        fi
    done
}

@test "Neovim configuration validation" {
    local nvim_config="$DOTFILES_DIR/.config/nvim"

    [ -d "$nvim_config" ]

    # Check for required structure
    local required_dirs=("lua/core" "lua/plugins")
    for dir in "${required_dirs[@]}"; do
        [ -d "$nvim_config/$dir" ]
    done

    # Check init.lua exists
    [ -f "$nvim_config/init.lua" ]

    # Check that there are Lua files
    local lua_files
    lua_files=$(find "$nvim_config" -name "*.lua" -type f | wc -l)
    [ "$lua_files" -gt 0 ]
}

@test "Git configuration validation" {
    local git_dir="$DOTFILES_DIR/git"
    local local_gitconfig="$git_dir/.gitconfig"
    local use_global=false

    # Determine which Git config to check
    if [[ -f "$local_gitconfig" ]]; then
        echo "Checking local dotfiles Git config: $local_gitconfig" >&3
    else
        echo "No local Git config found, checking global Git configuration" >&3
        use_global=true
    fi

    # Check for required configurations
    local required_configs=("user.name" "user.email" "core.editor")
    for config in "${required_configs[@]}"; do
        if [[ "$use_global" == "true" ]]; then
            # Check global Git configuration
            run git config --global --get "$config"
            [ "$status" -eq 0 ]
        else
            # Check local dotfiles Git configuration
            run git config --file "$local_gitconfig" --get "$config"
            [ "$status" -eq 0 ]
        fi
    done

    # Security: Check for hardcoded credentials (only in local config)
    if [[ "$use_global" == "false" ]]; then
        run grep -E "(password|token|secret)" "$local_gitconfig"
        [ "$status" -ne 0 ]  # Should NOT find credentials
    fi

    # Check .gitignore effectiveness
    local gitignore="$git_dir/.gitignore"
    if [[ -f "$gitignore" ]]; then
        local sensitive_patterns=(".env" "*.key" "*.pem" "config/secrets" "node_modules" ".DS_Store")
        for pattern in "${sensitive_patterns[@]}"; do
            run grep -q "$pattern" "$gitignore"
            [ "$status" -eq 0 ]
        done
    fi
}

@test "Starship configuration validation" {
    local starship_dir="$DOTFILES_DIR/.config/starship"

    [ -d "$starship_dir" ]

    # Check for theme files
    [ -d "$starship_dir/themes" ]

    # Validate TOML syntax in theme files
    local toml_files=0
    while IFS= read -r -d '' toml_file; do
        toml_files=$((toml_files + 1))
        # Basic TOML validation - check for proper section format
        run grep -q '\[.*\]' "$toml_file"
        [ "$status" -eq 0 ]
    done < <(find "$starship_dir" -name "*.toml" -type f -print0)

    [ "$toml_files" -gt 0 ]
}

@test "Package configuration validation" {
    local brewfile="$DOTFILES_DIR/install/Brewfile"

    [ -f "$brewfile" ]

    # Check for essential packages
    local essential_packages=("git" "zsh" "neovim" "starship")
    for package in "${essential_packages[@]}"; do
        run grep -q "brew \"$package\"" "$brewfile"
        [ "$status" -eq 0 ]
    done

    # Check for potential package conflicts
    local conflicting_pairs=("vim:neovim" "bash:zsh")
    for pair in "${conflicting_pairs[@]}"; do
        IFS=':' read -r pkg1 pkg2 <<< "$pair"
        local pkg1_found pkg2_found

        run grep -q "brew \"$pkg1\"" "$brewfile"
        pkg1_found=$status

        run grep -q "brew \"$pkg2\"" "$brewfile"
        pkg2_found=$status

        # If both are found, that's a potential conflict
        if [[ $pkg1_found -eq 0 && $pkg2_found -eq 0 ]]; then
            echo "Potential package conflict: $pkg1 and $pkg2" >&3
            return 1
        fi
    done
}