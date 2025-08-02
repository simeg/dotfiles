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

# Global configuration flags
INTERACTIVE_MODE=true
INSTALL_HOMEBREW=true
INSTALL_PACKAGES=true
INSTALL_ZSH=true
# INSTALL_VIM removed - using Neovim instead
SETUP_GIT=true
CREATE_SYMLINKS=true
BACKUP_EXISTING=true

# Interactive prompts
ask_yes_no() {
    local question="$1"
    local default="${2:-y}"
    local response

    if [[ "$INTERACTIVE_MODE" == false ]]; then
        return 0  # Default to yes in non-interactive mode
    fi

    while true; do
        if [[ "$default" == "y" ]]; then
            echo -n "$question [Y/n]: "
        else
            echo -n "$question [y/N]: "
        fi

        read -r response

        # Use default if empty response
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

# Interactive setup configuration
configure_interactive_setup() {
    echo "========================================="
    echo "         Interactive Dotfiles Setup"
    echo "========================================="
    echo

    log_info "Welcome! Let's configure your dotfiles setup."
    echo

    # Backup existing files
    if ask_yes_no "📦 Create backup of existing dotfiles?"; then
        BACKUP_EXISTING=true
    else
        BACKUP_EXISTING=false
    fi

    # Homebrew installation
    if command -v brew &> /dev/null; then
        log_info "✅ Homebrew is already installed"
        INSTALL_HOMEBREW=false
    else
        if ask_yes_no "🍺 Install Homebrew package manager?"; then
            INSTALL_HOMEBREW=true
        else
            INSTALL_HOMEBREW=false
            log_warning "Skipping Homebrew - some features may not work"
        fi
    fi

    # Package installation
    if [[ "$INSTALL_HOMEBREW" == true ]] || command -v brew &> /dev/null; then
        if ask_yes_no "📦 Install packages from Brewfile (recommended tools)?"; then
            INSTALL_PACKAGES=true
        else
            INSTALL_PACKAGES=false
        fi
    else
        INSTALL_PACKAGES=false
    fi

    # Zsh setup
    if ask_yes_no "🐚 Set up Zsh shell with plugins and configuration?"; then
        INSTALL_ZSH=true
    else
        INSTALL_ZSH=false
    fi

    # Neovim is now set up automatically via symlinks

    # Git configuration
    if ask_yes_no "🔧 Configure Git settings (user name, email, aliases)?"; then
        SETUP_GIT=true
    else
        SETUP_GIT=false
    fi

    # Symlinks
    if ask_yes_no "🔗 Create symlinks for dotfiles configuration?"; then
        CREATE_SYMLINKS=true
    else
        CREATE_SYMLINKS=false
    fi

    echo
    log_info "Configuration complete! Starting installation..."
    echo
}

# Show setup summary
show_setup_summary() {
    echo "========================================="
    echo "            Setup Summary"
    echo "========================================="
    echo "Backup existing files: $([ "$BACKUP_EXISTING" == true ] && echo "✅ Yes" || echo "❌ No")"
    echo "Install Homebrew: $([ "$INSTALL_HOMEBREW" == true ] && echo "✅ Yes" || echo "❌ No")"
    echo "Install packages: $([ "$INSTALL_PACKAGES" == true ] && echo "✅ Yes" || echo "❌ No")"
    echo "Setup Zsh: $([ "$INSTALL_ZSH" == true ] && echo "✅ Yes" || echo "❌ No")"
    echo "Setup Neovim: ✅ Yes (automatic via symlinks)"
    echo "Configure Git: $([ "$SETUP_GIT" == true ] && echo "✅ Yes" || echo "❌ No")"
    echo "Create symlinks: $([ "$CREATE_SYMLINKS" == true ] && echo "✅ Yes" || echo "❌ No")"
    echo "========================================="
    echo
}

# Check if we're on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is primarily designed for macOS"
        if ! ask_yes_no "Continue anyway? (some features may not work)"; then
            exit 1
        fi
    fi
}

# Backup existing dotfiles
backup_existing() {
    log_info "Backing up existing dotfiles..."
    BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    # List of files to backup
    local files_to_backup=(".zshrc" ".gitconfig" ".gitignore" ".ideavimrc")

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
    if ! ./scripts/install/brew.sh; then
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
    if ! ./scripts/install/zsh.sh; then
        log_error "Failed to install Zsh configuration"
        exit 1
    fi
    log_success "Zsh setup completed"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    log_info "Installing Oh My Zsh..."
    if ! ./scripts/install/oh-my-zsh.sh; then
        log_warning "Oh My Zsh installation failed, continuing..."
    else
        log_success "Oh My Zsh installation completed"
    fi
}


# Install Rust (if script exists)
install_rust() {
    if [[ -f "scripts/install/rust.sh" ]]; then
        log_info "Installing Rust..."
        if ! ./scripts/install/rust.sh; then
            log_warning "Rust installation failed, continuing..."
        else
            log_success "Rust installation completed"
        fi
    fi
}

# Install macOS specific settings
install_macos_settings() {
    if [[ -f "scripts/install/macOS/macOS.sh" ]]; then
        log_info "Applying macOS settings..."
        if ! ./scripts/install/macOS/macOS.sh; then
            log_warning "macOS settings application failed, continuing..."
        else
            log_success "macOS settings applied"
        fi
    fi
}

# Create symlinks
create_symlinks() {
    log_info "Creating symlinks..."
    if ! ./scripts/symlink.sh; then
        log_error "Failed to create symlinks"
        exit 1
    fi
    log_success "Symlinks created successfully"
}

# Make scripts executable
make_scripts_executable() {
    log_info "Making scripts executable..."
    find . -name "*.sh" -exec chmod +x {} \;
    chmod +x scripts/symlink.sh scripts/shellcheck.sh
    if [[ -d "scripts/bin" ]]; then
        find scripts/bin -type f -exec chmod +x {} \;
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

    # Run interactive configuration if enabled
    if [[ "$INTERACTIVE_MODE" == true ]]; then
        configure_interactive_setup
        show_setup_summary
    fi

    # Pre-installation checks
    check_macos
    make_scripts_executable

    # Backup existing configuration
    if [[ "$BACKUP_EXISTING" == true ]]; then
        backup_existing
    fi

    # Install dependencies
    if [[ "$INSTALL_HOMEBREW" == true ]]; then
        install_homebrew
    fi

    if [[ "$INSTALL_PACKAGES" == true ]]; then
        install_packages
    fi

    # Install configurations
    if [[ "$INSTALL_ZSH" == true ]]; then
        install_zsh
        install_oh_my_zsh
    fi

    # Neovim configuration is now handled automatically via symlinks

    # Always try rust and macOS settings (they check internally)
    install_rust
    install_macos_settings

    # Create symlinks
    if [[ "$CREATE_SYMLINKS" == true ]]; then
        create_symlinks
    fi

    # Post-installation
    run_lint

    log_success "Dotfiles installation completed successfully!"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
    if [[ "$BACKUP_EXISTING" == true ]]; then
        log_info "Backup of previous dotfiles: $BACKUP_DIR"
    fi

    # Suggest next steps
    echo
    log_info "Next steps:"
    echo "  1. Run './scripts/validate.sh' to verify the installation"
    echo "  2. Run './scripts/profile-shell.sh --startup' to check performance"
    echo "  3. Create ~/.config/zsh/private.zsh for sensitive environment variables"
}

# Show usage information
show_usage() {
    echo "Dotfiles Setup Script"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  --non-interactive   Run without interactive prompts (auto-install everything)"
    echo "  --no-backup         Skip backing up existing dotfiles"
    echo "  --brew-only         Only install Homebrew and packages"
    echo "  --symlink-only      Only create symlinks"
    echo "  --deps-only         Only check and install dependencies"
    echo "  --minimal           Minimal installation (essential tools only)"
    echo ""
    echo "Examples:"
    echo "  $0                      # Interactive setup (recommended)"
    echo "  $0 --non-interactive    # Auto-install everything"
    echo "  $0 --minimal            # Install only essential tools"
    echo "  $0 --brew-only          # Only setup Homebrew and packages"
    echo ""
}

# Parse command line arguments
BREW_ONLY=false
SYMLINK_ONLY=false
DEPS_ONLY=false
# MINIMAL variable removed - was unused

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        --non-interactive)
            INTERACTIVE_MODE=false
            shift
            ;;
        --no-backup)
            BACKUP_EXISTING=false
            shift
            ;;
        --brew-only)
            BREW_ONLY=true
            INTERACTIVE_MODE=false
            shift
            ;;
        --symlink-only)
            SYMLINK_ONLY=true
            INTERACTIVE_MODE=false
            shift
            ;;
        --deps-only)
            DEPS_ONLY=true
            INTERACTIVE_MODE=false
            shift
            ;;
        --minimal)
            # Set minimal configuration
            INSTALL_PACKAGES=false
            # INSTALL_VIM removed - using Neovim instead
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
    log_info "Running Homebrew-only installation..."
    cd "$(dirname "$0")"
    check_macos
    install_homebrew
    install_packages
elif [[ "$SYMLINK_ONLY" == true ]]; then
    log_info "Creating symlinks only..."
    cd "$(dirname "$0")"
    create_symlinks
elif [[ "$DEPS_ONLY" == true ]]; then
    log_info "Checking dependencies only..."
    cd "$(dirname "$0")"
    ./scripts/check-deps.sh
else
    # Run full installation
    main
fi
