#!/usr/bin/env bash

# Comprehensive dotfiles setup script
# This script handles the complete installation of dotfiles and dependencies

set -e

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

# Check if we're on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS only"
        exit 1
    fi
}

# Backup existing dotfiles
backup_existing() {
    log_info "Backing up existing dotfiles..."
    BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    # List of files to backup
    local files_to_backup=(".zshrc" ".gitconfig" ".gitignore" ".vim" ".ideavimrc")

    for file in "${files_to_backup[@]}"; do
        if [[ -e "$HOME/$file" ]]; then
            log_info "Backing up $HOME/$file"
            cp -r "$HOME/$file" "$BACKUP_DIR/"
        fi
    done

    log_success "Backup created at $BACKUP_DIR"
}

# Install Homebrew
install_homebrew() {
    log_info "Installing Homebrew..."
    if ! ./install/brew.sh; then
        log_error "Failed to install Homebrew"
        exit 1
    fi

    # Add Homebrew to PATH for this session
    if [[ -d "/opt/homebrew/bin" ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
    elif [[ -d "/usr/local/bin" ]]; then
        export PATH="/usr/local/bin:$PATH"
    fi

    log_success "Homebrew installation completed"
}

# Install packages from Brewfile
install_packages() {
    log_info "Installing packages from Brewfile..."
    if [[ -f "install/Brewfile" ]]; then
        brew bundle --file=install/Brewfile
        log_success "Package installation completed"
    else
        log_warning "Brewfile not found, skipping package installation"
    fi
}

# Install Zsh configuration
install_zsh() {
    log_info "Setting up Zsh..."
    if ! ./install/zsh.sh; then
        log_error "Failed to install Zsh configuration"
        exit 1
    fi
    log_success "Zsh setup completed"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    log_info "Installing Oh My Zsh..."
    if ! ./install/oh-my-zsh.sh; then
        log_warning "Oh My Zsh installation failed, continuing..."
    else
        log_success "Oh My Zsh installation completed"
    fi
}

# Install Vim configuration
install_vim() {
    log_info "Setting up Vim..."
    if ! ./install/vim.sh; then
        log_error "Failed to install Vim configuration"
        exit 1
    fi
    log_success "Vim setup completed"
}

# Install Rust (if script exists)
install_rust() {
    if [[ -f "install/rust.sh" ]]; then
        log_info "Installing Rust..."
        if ! ./install/rust.sh; then
            log_warning "Rust installation failed, continuing..."
        else
            log_success "Rust installation completed"
        fi
    fi
}

# Install macOS specific settings
install_macos_settings() {
    if [[ -f "install/macOS/macOS.sh" ]]; then
        log_info "Applying macOS settings..."
        if ! ./install/macOS/macOS.sh; then
            log_warning "macOS settings application failed, continuing..."
        else
            log_success "macOS settings applied"
        fi
    fi
}

# Create symlinks
create_symlinks() {
    log_info "Creating symlinks..."
    if ! ./symlink.sh; then
        log_error "Failed to create symlinks"
        exit 1
    fi
    log_success "Symlinks created successfully"
}

# Make scripts executable
make_scripts_executable() {
    log_info "Making scripts executable..."
    find install -name "*.sh" -exec chmod +x {} \;
    chmod +x symlink.sh shellcheck.sh
    if [[ -d "bin" ]]; then
        find bin -type f -exec chmod +x {} \;
    fi
    log_success "Scripts made executable"
}

# Run linting
run_lint() {
    log_info "Running shellcheck linting..."
    if command -v shellcheck >/dev/null 2>&1; then
        if make lint; then
            log_success "Linting passed"
        else
            log_warning "Linting found issues, check output above"
        fi
    else
        log_warning "shellcheck not found, skipping linting"
    fi
}

# Main installation function
main() {
    log_info "Starting dotfiles installation..."

    # Change to script directory
    cd "$(dirname "$0")"

    # Pre-installation checks
    check_macos
    make_scripts_executable

    # Backup existing configuration
    backup_existing

    # Install dependencies
    install_homebrew
    install_packages

    # Install configurations
    install_zsh
    install_oh_my_zsh
    install_vim
    install_rust
    install_macos_settings

    # Create symlinks
    create_symlinks

    # Post-installation
    run_lint

    log_success "Dotfiles installation completed successfully!"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
    log_info "Backup of previous dotfiles: $BACKUP_DIR"
}

# Show usage information
show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --no-backup    Skip backing up existing dotfiles"
    echo "  --brew-only    Only install Homebrew and packages"
    echo "  --symlink-only Only create symlinks"
    echo ""
}

# Parse command line arguments
BACKUP=true
BREW_ONLY=false
SYMLINK_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        --no-backup)
            BACKUP=false
            shift
            ;;
        --brew-only)
            BREW_ONLY=true
            shift
            ;;
        --symlink-only)
            SYMLINK_ONLY=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Execute based on options
if [[ "$BREW_ONLY" == true ]]; then
    check_macos
    install_homebrew
    install_packages
elif [[ "$SYMLINK_ONLY" == true ]]; then
    cd "$(dirname "$0")"
    create_symlinks
else
    if [[ "$BACKUP" == false ]]; then
        backup_existing() { log_info "Skipping backup as requested"; }
    fi
    main
fi
