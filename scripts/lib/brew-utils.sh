#!/usr/bin/env bash

# Standardized Homebrew operations
# This file consolidates duplicated Homebrew functionality across scripts

# Source common utilities (only if not already sourced)
if [[ -z "${_COMMON_SOURCED:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # shellcheck source=scripts/lib/common.sh
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/common.sh"
fi

# Check if Homebrew is installed
check_homebrew_installed() {
    if ! check_command_exists "brew"; then
        log_error "Homebrew is not installed"
        log_info "Install Homebrew from: https://brew.sh"
        return 1
    fi
    return 0
}

# Check if packages in Brewfile are installed
check_brewfile_packages() {
    local brewfile="$1"
    
    if [[ ! -f "$brewfile" ]]; then
        log_error "Brewfile not found: $brewfile"
        return 1
    fi
    
    if ! check_homebrew_installed; then
        return 1
    fi
    
    brew bundle check --file="$brewfile" &>/dev/null
}

# Install packages from Brewfile
install_brewfile_packages() {
    local brewfile="$1"
    local force_flag="${2:-false}"
    
    if [[ ! -f "$brewfile" ]]; then
        log_error "Brewfile not found: $brewfile"
        return 1
    fi
    
    if ! check_homebrew_installed; then
        return 1
    fi
    
    log_info "Installing packages from $(basename "$brewfile")..."
    
    local brew_cmd="brew bundle --file=$brewfile"
    if [[ "$force_flag" == "true" ]]; then
        brew_cmd="$brew_cmd --force"
    fi
    
    if eval "$brew_cmd"; then
        log_success "Packages installed successfully from $(basename "$brewfile")"
        return 0
    else
        log_warning "Some packages failed to install from $(basename "$brewfile")"
        return 1
    fi
}

# Install packages with conflict resolution
install_brewfile_with_conflicts() {
    local brewfile="$1"
    
    if [[ ! -f "$brewfile" ]]; then
        log_error "Brewfile not found: $brewfile"
        return 1
    fi
    
    if ! check_homebrew_installed; then
        return 1
    fi
    
    # First attempt
    if install_brewfile_packages "$brewfile"; then
        return 0
    fi
    
    # If failed, try to resolve common conflicts
    log_info "Attempting to resolve package conflicts..."
    resolve_brew_conflicts
    
    # Second attempt after conflict resolution
    if install_brewfile_packages "$brewfile"; then
        log_success "Packages installed after conflict resolution"
        return 0
    else
        log_warning "Some packages failed to install even after conflict resolution"
        return 1
    fi
}

# Resolve common Homebrew conflicts
resolve_brew_conflicts() {
    local packages=("openssl@3" "pyenv" "zsh")
    
    for package in "${packages[@]}"; do
        if check_command_exists "brew" && brew list "$package" &>/dev/null; then
            log_debug "Attempting to force link $package"
            brew link --overwrite --force "$package" 2>/dev/null || true
        fi
    done
}

# Update Homebrew and packages
update_homebrew() {
    if ! check_homebrew_installed; then
        return 1
    fi
    
    log_info "Updating Homebrew..."
    if brew update; then
        log_success "Homebrew updated successfully"
        return 0
    else
        log_error "Failed to update Homebrew"
        return 1
    fi
}

# Get list of missing packages from Brewfile
get_missing_brewfile_packages() {
    local brewfile="$1"
    
    if [[ ! -f "$brewfile" ]]; then
        log_error "Brewfile not found: $brewfile"
        return 1
    fi
    
    if ! check_homebrew_installed; then
        return 1
    fi
    
    # Get missing packages output
    local missing_output
    missing_output=$(brew bundle check --file="$brewfile" 2>&1 | grep -E "(not installed|not found)" || true)
    
    if [[ -n "$missing_output" ]]; then
        echo "$missing_output"
        return 1
    else
        return 0
    fi
}

# Install Mac App Store apps if available
install_mas_apps() {
    local brewfile_mas="${1:-install/Brewfile.mas}"
    
    # Skip in CI environment
    if is_ci; then
        log_info "Skipping Mac App Store apps in CI environment"
        return 0
    fi
    
    if [[ ! -f "$brewfile_mas" ]]; then
        log_debug "Mac App Store Brewfile not found: $brewfile_mas"
        return 0
    fi
    
    if ! check_command_exists "mas"; then
        log_warning "mas CLI not found, skipping Mac App Store apps"
        log_info "Install mas with: brew install mas"
        return 1
    fi
    
    log_info "Installing Mac App Store apps..."
    if install_brewfile_packages "$brewfile_mas"; then
        log_success "Mac App Store apps installed"
        return 0
    else
        log_warning "Some Mac App Store apps failed to install"
        return 1
    fi
}

# Count packages in Brewfile
count_brewfile_packages() {
    local brewfile="$1"
    
    if [[ ! -f "$brewfile" ]]; then
        echo "0"
        return 1
    fi
    
    # Count non-comment, non-empty lines that look like package definitions
    grep -cE '^(brew|cask|mas)' "$brewfile" 2>/dev/null | tr -d ' '
}

# Validate Brewfile syntax
validate_brewfile() {
    local brewfile="$1"
    
    if [[ ! -f "$brewfile" ]]; then
        log_error "Brewfile not found: $brewfile"
        return 1
    fi
    
    if ! check_homebrew_installed; then
        return 1
    fi
    
    # Test bundle file syntax without installing
    if brew bundle check --file="$brewfile" --dry-run &>/dev/null; then
        log_success "Brewfile syntax is valid: $(basename "$brewfile")"
        return 0
    else
        log_error "Brewfile syntax error: $(basename "$brewfile")"
        return 1
    fi
}

# Get Homebrew system information
get_brew_info() {
    if ! check_homebrew_installed; then
        return 1
    fi
    
    log_info "Homebrew Information:"
    echo "  Version: $(brew --version | head -1)"
    echo "  Prefix: $(brew --prefix)"
    echo "  Repository: $(brew --repository)"
    
    # Get installed package count
    local package_count
    package_count=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
    echo "  Installed packages: $package_count"
    
    local cask_count
    cask_count=$(brew list --cask 2>/dev/null | wc -l | tr -d ' ')
    echo "  Installed casks: $cask_count"
}