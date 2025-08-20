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
    local zshrc="$HOME/.zshrc"
    local source_zshrc="$DOTFILES_DIR/.config/zsh/.zshrc"

    # Private config should exist or be mentioned in docs
    if [[ ! -f "$private_config" ]]; then
        echo "Private config not found at $private_config (this is normal for new setups)" >&3

        # Check if it would be sourced correctly if it existed
        # In CI environment, check the source .zshrc instead of symlinked version
        if [[ -f "$zshrc" ]]; then
            run grep -q "private.zsh" "$zshrc"
            [ "$status" -eq 0 ]
        elif [[ -f "$source_zshrc" ]]; then
            echo "Testing source .zshrc for private config reference (CI environment)" >&3
            run grep -q "private.zsh" "$source_zshrc"
            [ "$status" -eq 0 ]
        else
            echo "No .zshrc found to test private config reference" >&3
            return 1
        fi
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
    # In CI environment, we test the plugin configuration syntax without requiring installation
    local znap_dir="$HOME/.zsh/znap"
    local plugins_file="$HOME/.znap-plugins.zsh"
    local source_plugins_file="$DOTFILES_DIR/.config/zsh/.znap-plugins.zsh"

    # Check if znap is installed (skip in CI if not installed)
    if [[ -d "$znap_dir" ]]; then
        echo "znap directory found at $znap_dir" >&3

        # Check if znap plugins file exists
        [ -f "$plugins_file" ]

        # Test znap plugins file syntax
        run zsh -n "$plugins_file"
        [ "$status" -eq 0 ]
    elif [[ -f "$source_plugins_file" ]]; then
        echo "Testing source plugins file (CI environment): $source_plugins_file" >&3

        # Test source plugins file syntax
        run zsh -n "$source_plugins_file"
        [ "$status" -eq 0 ]
    else
        echo "znap not installed and no source plugins file found (skipping for CI)" >&3
        skip "znap plugins not installed in CI environment"
    fi
}

@test "Starship prompt configuration" {
    # Check if starship is installed (skip in CI if not available)
    run command -v starship
    if [ "$status" -ne 0 ]; then
        echo "starship not installed (skipping for CI environment)" >&3
        skip "starship not available in CI environment"
    fi

    # Check if starship config exists and is readable
    local config_file="$HOME/.config/starship.toml"
    local source_config="$DOTFILES_DIR/.config/starship.toml"

    if [[ -f "$config_file" ]]; then
        echo "Testing installed starship config: $config_file" >&3
        # Basic TOML syntax validation (check for basic structure)
        run grep -q '\[' "$config_file"
        [ "$status" -eq 0 ]
    elif [[ -f "$source_config" ]]; then
        echo "Testing source starship config (CI environment): $source_config" >&3
        # Basic TOML syntax validation (check for basic structure)
        run grep -q '\[' "$source_config"
        [ "$status" -eq 0 ]
    else
        echo "No starship config found (this is normal for minimal setups)" >&3
        skip "starship config not found"
    fi
}

@test "Neovim configuration" {
    local ideavimrc="$HOME/.ideavimrc"
    local nvim_config="$HOME/.config/nvim"
    local source_ideavimrc="$DOTFILES_DIR/.ideavimrc"
    local source_nvim_config="$DOTFILES_DIR/.config/nvim"

    # Check if Neovim config directory exists (installed or source)
    if [[ -d "$nvim_config" ]]; then
        echo "Found nvim config directory: $nvim_config" >&3
    elif [[ -d "$source_nvim_config" ]]; then
        echo "Testing source nvim config (CI environment): $source_nvim_config" >&3
    else
        echo "No nvim config directory found (skipping for CI)" >&3
        skip "neovim config not found in CI environment"
    fi

    # Check if .ideavimrc exists (for JetBrains IDEs)
    local test_ideavimrc=""
    if [[ -f "$ideavimrc" ]]; then
        test_ideavimrc="$ideavimrc"
        echo "Testing installed .ideavimrc: $ideavimrc" >&3
    elif [[ -f "$source_ideavimrc" ]]; then
        test_ideavimrc="$source_ideavimrc"
        echo "Testing source .ideavimrc (CI environment): $source_ideavimrc" >&3
    else
        echo "No .ideavimrc found (this is optional)" >&3
        return 0  # .ideavimrc is optional, so don't fail
    fi

    # Basic ideavimrc syntax check
    if [[ -n "$test_ideavimrc" && -f "$test_ideavimrc" ]]; then
        # Check for basic syntax by looking for vim-specific patterns
        run grep -q "set\|let\|map\|source" "$test_ideavimrc"
        [ "$status" -eq 0 ]
    fi
}

@test "Git configuration" {
    # Check if git is configured (in CI, this might not be set)
    run git config --get user.name
    local name_status=$status

    run git config --get user.email
    local email_status=$status

    # In CI environment, git user might not be configured, so check git config files instead
    if [[ $name_status -ne 0 || $email_status -ne 0 ]]; then
        echo "Git user not configured globally (common in CI), checking config files exist" >&3

        # Check if git config files exist in the dotfiles
        if [[ -f "$DOTFILES_DIR/git/.gitconfig" ]] || [[ -f "$DOTFILES_DIR/.gitconfig" ]]; then
            echo "Git config files found in dotfiles" >&3
            return 0
        elif [[ -d "$DOTFILES_DIR/git" ]]; then
            echo "Git directory found, config files may be modular" >&3
            return 0
        else
            echo "No git configuration found in dotfiles (this might be in private config)" >&3
            skip "git user configuration not found in CI environment"
        fi
    else
        echo "Git user configuration found" >&3
    fi
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