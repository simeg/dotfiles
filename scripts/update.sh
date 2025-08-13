#!/usr/bin/env bash

# Update script for dotfiles
# Pulls latest changes and selectively updates configurations

# Source shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=scripts/lib/brew-utils.sh
source "$SCRIPT_DIR/lib/brew-utils.sh"
# shellcheck source=scripts/lib/validation-utils.sh
source "$SCRIPT_DIR/lib/validation-utils.sh"
# shellcheck source=scripts/lib/error-handling.sh
source "$SCRIPT_DIR/lib/error-handling.sh"

# Initialize error handling
setup_error_handling "update.sh" true

# Update-specific state
ORIGINAL_BRANCH=""
# shellcheck disable=SC2034  # UPDATE_FAILED is used for error tracking
UPDATE_FAILED=false

# Custom cleanup function for update-specific cleanup
cleanup_on_error() {
    # shellcheck disable=SC2034  # UPDATE_FAILED is used for error tracking
    UPDATE_FAILED=true
    
    log_warning "Performing update-specific cleanup..."
    
    # If we were pulling changes and it failed, offer to reset
    if [[ -n "$ORIGINAL_BRANCH" ]] && git rev-parse --git-dir > /dev/null 2>&1; then
        if confirm "❌ Git update failed. Reset to original state?" "y"; then
            log_info "Resetting to original branch state..."
            git reset --hard HEAD 2>/dev/null || true
            git clean -fd 2>/dev/null || true
            log_info "Repository reset completed after update failure"
        else
            log_warning "Update failed but repository reset was skipped"
        fi
    else
        log_warning "Update failed outside of git context"
    fi
}

# Check if we're in a git repository (enhanced with validation utilities)
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "This script must be run from within the dotfiles git repository"
        exit 1
    fi
    log_debug "Confirmed running in git repository"
}

# Check for uncommitted changes
check_uncommitted_changes() {
    if ! git diff-index --quiet HEAD --; then
        log_warning "You have uncommitted changes in your dotfiles repository"
        read -p "Do you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Update cancelled"
            exit 0
        fi
    fi
}

# Pull latest changes
pull_latest() {
    # Skip git pull in CI environments since they already have the latest code
    if [[ "$DOTFILES_CI" == "true" ]] || [[ -n "$CI" ]] || [[ -n "$GITHUB_ACTIONS" ]]; then
        log_info "Skipping git pull in CI environment (code already at latest version)"
        return 0
    fi

    log_info "Pulling latest changes from remote..."

    local current_branch
    current_branch=$(git branch --show-current)
    ORIGINAL_BRANCH="$current_branch"

    # Store current commit hash for potential rollback
    local original_commit
    original_commit=$(git rev-parse HEAD)

    if git pull origin "$current_branch"; then
        log_success "Successfully pulled latest changes"
    else
        log_error "Failed to pull latest changes"
        log_info "You can manually reset with: git reset --hard $original_commit"
        exit 1
    fi
}

# Update Homebrew packages
update_homebrew() {
    log_info "Updating Homebrew packages..."

    if command -v brew >/dev/null 2>&1; then
        # Update Homebrew using shared utilities
        update_homebrew
        
        if [[ -f "install/Brewfile" ]]; then
            install_brewfile_packages "install/Brewfile"
            log_success "Core packages updated from Brewfile"
            
            # Update Mac App Store apps using shared utilities
            install_mas_apps "install/Brewfile.mas"
                fi
            else
                if [[ "$DOTFILES_CI" == "true" ]]; then
                    log_info "Skipping Mac App Store apps in CI environment"
                fi
            fi
        else
            log_warning "Brewfile not found, skipping package updates"
        fi
    else
        log_warning "Homebrew not found, skipping package updates"
    fi
}

# Update Neovim plugins
update_nvim_plugins() {
    # Skip plugin updates in CI environments to avoid authentication issues
    if [[ "$DOTFILES_CI" == "true" ]] || [[ -n "$CI" ]] || [[ -n "$GITHUB_ACTIONS" ]]; then
        log_info "Skipping Neovim plugin updates in CI environment (fresh installation already has latest)"
        return 0
    fi

    log_info "Updating Neovim plugins..."

    if command -v nvim >/dev/null 2>&1; then
        if [[ -d "$HOME/.config/nvim" ]]; then
            nvim --headless "+Lazy! sync" +qa
            log_success "Neovim plugins updated"
        else
            log_warning "Neovim config not found, skipping plugin updates"
        fi
    else
        log_warning "Neovim not found, skipping plugin updates"
    fi
}

# Update zsh plugins
update_zsh_plugins() {
    # Skip plugin updates in CI environments to avoid authentication issues
    if [[ "$DOTFILES_CI" == "true" ]] || [[ -n "$CI" ]] || [[ -n "$GITHUB_ACTIONS" ]]; then
        log_info "Skipping Zsh plugin updates in CI environment (fresh installation already has latest)"
        return 0
    fi

    log_info "Updating Zsh plugins..."

    if [[ -d "$HOME/.zsh/znap" ]]; then
        # Update znap itself
        if [[ -d "$HOME/.zsh/znap/.git" ]]; then
            git -C "$HOME/.zsh/znap" pull
        fi

        # Update znap plugins if znap is available
        if command -v znap >/dev/null 2>&1; then
            znap pull
            log_success "Zsh plugins updated"
        else
            log_warning "znap command not available, manual plugin update may be needed"
        fi
    else
        log_warning "znap not found, skipping zsh plugin updates"
    fi
}

# Update symlinks
update_symlinks() {
    log_info "Updating symlinks..."

    if [[ -f "scripts/symlink.sh" ]]; then
        ./scripts/symlink.sh
        log_success "Symlinks updated"
    else
        log_error "symlink.sh not found"
        exit 1
    fi
}

# Run linting
run_lint() {
    log_info "Running linting checks..."

    if command -v shellcheck >/dev/null 2>&1; then
        if make lint; then
            log_success "Linting passed"
        else
            log_warning "Linting found issues, please review"
        fi
    else
        log_warning "shellcheck not found, skipping linting"
    fi
}

# Show what changed
show_changes() {
    log_info "Recent changes:"
    git log --oneline -10 --color=always
}

# Main update function
main_update() {
    log_info "Starting dotfiles update..."

    # Change to dotfiles root directory
    cd "$(dirname "$0")/.."

    # Pre-update checks
    check_git_repo
    check_uncommitted_changes

    # Show current status
    log_info "Current branch: $(git branch --show-current)"
    log_info "Last commit: $(git log -1 --oneline)"

    # Pull changes
    pull_latest

    # Update components based on flags
    if [[ "$UPDATE_BREW" == true ]]; then
        update_homebrew
    fi

    if [[ "$UPDATE_NVIM" == true ]]; then
        update_nvim_plugins
    fi

    if [[ "$UPDATE_ZSH" == true ]]; then
        update_zsh_plugins
    fi

    if [[ "$UPDATE_SYMLINKS" == true ]]; then
        update_symlinks
    fi

    # Post-update checks
    if [[ "$RUN_LINT" == true ]]; then
        run_lint
    fi

    # Show what changed
    show_changes

    log_success "Dotfiles update completed!"
    log_info "You may need to restart your terminal or run 'source ~/.zshrc' for some changes to take effect"
}

# Show usage information
show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help         Show this help message"
    echo "  --all              Update everything (default)"
    echo "  --brew-only        Only update Homebrew packages"
    echo "  --nvim-only        Only update Neovim plugins"
    echo "  --zsh-only         Only update Zsh plugins"
    echo "  --symlinks-only    Only update symlinks"
    echo "  --no-brew          Skip Homebrew updates"
    echo "  --no-nvim          Skip Neovim plugin updates"
    echo "  --no-zsh           Skip Zsh plugin updates"
    echo "  --no-symlinks      Skip symlink updates"
    echo "  --no-lint          Skip linting checks"
    echo "  --git-only         Only pull git changes, no updates"
    echo ""
}

# Parse command line arguments
UPDATE_BREW=true
UPDATE_NVIM=true
UPDATE_ZSH=true
UPDATE_SYMLINKS=true
RUN_LINT=true

# Store original arguments for proper parsing
ORIGINAL_ARGS=("$@")

# Check for specific only flags first
for arg in "${ORIGINAL_ARGS[@]}"; do
    case $arg in
        --brew-only|--nvim-only|--zsh-only|--symlinks-only|--git-only)
            UPDATE_BREW=false
            UPDATE_NVIM=false
            UPDATE_ZSH=false
            UPDATE_SYMLINKS=false
            RUN_LINT=false
            break
            ;;
    esac
done

# Parse all arguments
set -- "${ORIGINAL_ARGS[@]}"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        --all)
            UPDATE_BREW=true
            UPDATE_NVIM=true
            UPDATE_ZSH=true
            UPDATE_SYMLINKS=true
            RUN_LINT=true
            shift
            ;;
        --brew-only)
            UPDATE_BREW=true
            shift
            ;;
        --nvim-only)
            UPDATE_NVIM=true
            shift
            ;;
        --zsh-only)
            UPDATE_ZSH=true
            shift
            ;;
        --symlinks-only)
            UPDATE_SYMLINKS=true
            shift
            ;;
        --git-only)
            # Only pull changes, no updates
            shift
            ;;
        --no-brew)
            UPDATE_BREW=false
            shift
            ;;
        --no-nvim)
            UPDATE_NVIM=false
            shift
            ;;
        --no-zsh)
            UPDATE_ZSH=false
            shift
            ;;
        --no-symlinks)
            UPDATE_SYMLINKS=false
            shift
            ;;
        --no-lint)
            RUN_LINT=false
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Execute update
main_update
