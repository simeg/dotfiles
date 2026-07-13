#!/usr/bin/env bats

# Advanced configuration validation tests migrated from test_advanced.sh
# Tests comprehensive configuration validation

load setup_suite

@test "Zsh configuration validation" {
    ensure_dotfiles_dir
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

@test "Git configuration validation" {
    ensure_dotfiles_dir
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

# Note: Neovim structure, Starship TOML, and Brewfile validation live in
# test_ci.bats (the portable, canonical home for those checks).
