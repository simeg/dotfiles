#!/usr/bin/env bash

# Update script for dotfiles
# Pulls latest changes and selectively updates configurations

set -e

# Enhanced error handling
ORIGINAL_BRANCH=""
# shellcheck disable=SC2034  # UPDATE_FAILED is used in error handler
UPDATE_FAILED=false

# Cleanup function
cleanup_on_error() {
    local exit_code=$?
    # shellcheck disable=SC2034  # UPDATE_FAILED is used for error tracking
    UPDATE_FAILED=true
    
    log_error "Update failed with exit code $exit_code"
    log_error "Last command: $BASH_COMMAND"
    
    # If we were pulling changes and it failed, offer to reset
    if [[ -n "$ORIGINAL_BRANCH" ]] && git rev-parse --git-dir > /dev/null 2>&1; then
        if ask_yes_no "❌ Git update failed. Reset to original state?" "y"; then
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
    
    exit $exit_code
}

# Simple yes/no prompt for error handling
ask_yes_no() {
    local question="$1"
    local default="${2:-y}"
    local response
    
    while true; do
        if [[ "$default" == "y" ]]; then
            echo -n "$question [Y/n]: "
        else
            echo -n "$question [y/N]: "
        fi
        
        read -r response
        
        if [[ -z "$response" ]]; then
            response="$default"
        fi
        
        case "$response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo]) return 1 ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}

trap 'cleanup_on_error' ERR

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "This script must be run from within the dotfiles git repository"
        exit 1
    fi
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
        brew update
        if [[ -f "install/Brewfile" ]]; then
            brew bundle --file=install/Brewfile
            log_success "Homebrew packages updated"
        else
            log_warning "Brewfile not found, skipping package updates"
        fi
    else
        log_warning "Homebrew not found, skipping package updates"
    fi
}

# Update Neovim plugins
update_nvim_plugins() {
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

# Check for specific only flags first
while [[ $# -gt 0 ]]; do
    case $1 in
        --brew-only|--nvim-only|--zsh-only|--symlinks-only|--git-only)
            UPDATE_BREW=false
            UPDATE_NVIM=false
            UPDATE_ZSH=false
            UPDATE_SYMLINKS=false
            RUN_LINT=false
            break
            ;;
        *)
            shift
            ;;
    esac
done

# Reset argument parsing
set -- "$@"

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
