#!/usr/bin/env bash

# Comprehensive dotfiles setup script
# This script handles the complete installation of dotfiles and dependencies

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=scripts/lib/brew-utils.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/brew-utils.sh"

# Global error handling
# shellcheck disable=SC2034  # SETUP_FAILED is used in error handler
SETUP_FAILED=false
ROLLBACK_COMMANDS=()

# Add command to rollback list
add_rollback() {
    ROLLBACK_COMMANDS+=("$1")
}

# Execute rollback commands in reverse order
execute_rollback() {
    if [[ ${#ROLLBACK_COMMANDS[@]} -eq 0 ]]; then
        return
    fi

    log_warning "Executing rollback commands..."

    # Execute in reverse order
    for (( i=${#ROLLBACK_COMMANDS[@]}-1 ; i>=0 ; i-- )); do
        log_info "Rolling back: ${ROLLBACK_COMMANDS[i]}"
        eval "${ROLLBACK_COMMANDS[i]}" || log_warning "Rollback command failed: ${ROLLBACK_COMMANDS[i]}"
    done
}

# Error handler
handle_error() {
    local exit_code=$?
    # shellcheck disable=SC2034  # SETUP_FAILED is used for error tracking
    SETUP_FAILED=true

    log_error "Setup failed with exit code $exit_code"
    log_error "Last command: $BASH_COMMAND"

    if [[ ${#ROLLBACK_COMMANDS[@]} -gt 0 ]]; then
        if ask_yes_no "❌ Setup failed. Do you want to rollback changes?" "y"; then
            execute_rollback
            log_info "Setup was rolled back due to failure"
        else
            log_warning "Setup failed but rollback was skipped"
        fi
    else
        log_warning "Setup failed with no rollback actions available"
    fi

    exit $exit_code
}

# Set error trap
trap 'handle_error' ERR

# Note: Color output and logging functions are now sourced from common.sh

# Custom cleanup function for setup-specific cleanup
cleanup_on_error() {
    # This function is called by the shared error handler
    log_warning "Performing setup-specific cleanup..."
    # Add any setup-specific cleanup logic here
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
ENABLE_ANALYTICS=false

# Auto-detect CI environments and disable interactive mode
if [[ "$DOTFILES_CI" == "true" ]] || [[ -n "$CI" ]] || [[ -n "$GITHUB_ACTIONS" ]]; then
    log_info "CI environment detected, enabling non-interactive mode"
    INTERACTIVE_MODE=false
fi

# Interactive prompts (enhanced with shared confirm function)
ask_yes_no() {
    local question="$1"
    local default="${2:-y}"

    if [[ "$INTERACTIVE_MODE" == false ]]; then
        return 0  # Default to yes in non-interactive mode
    fi

    # Use shared confirm function
    confirm "$question" "$default"
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

    # Analytics (optional for advanced users)
    if ask_yes_no "📊 Enable analytics and performance monitoring? (advanced feature)" "n"; then
        ENABLE_ANALYTICS=true
        log_info "Analytics enabled - you can use 'make analytics' for insights"
    else
        ENABLE_ANALYTICS=false
        log_info "Analytics disabled - keeping setup simple"
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
    echo "Enable analytics: $([ "$ENABLE_ANALYTICS" == true ] && echo "✅ Yes" || echo "❌ No")"
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
    add_rollback "rm -rf '$BACKUP_DIR'"

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

    # Only add rollback if Homebrew wasn't already installed
    if ! command -v brew &> /dev/null; then
        # shellcheck disable=SC2016  # Single quotes intentional - command evaluated later during rollback
        add_rollback 'if command -v brew &> /dev/null; then /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"; fi'
    fi

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

    # Use minimal Brewfile in CI for speed
    local brewfile="install/Brewfile"
    if [[ "$DOTFILES_CI" == "true" ]] && [[ -f "install/Brewfile.ci-minimal" ]]; then
        brewfile="install/Brewfile.ci-minimal"
        log_info "Using minimal CI Brewfile for faster installation"

        # Handle common CI package conflicts
        log_info "Resolving package conflicts in CI environment..."
        brew unlink openssl@1.1 2>/dev/null || true
        brew unlink zsh 2>/dev/null || true
        brew unlink pyenv 2>/dev/null || true
    fi

    if [[ -f "$brewfile" ]]; then
        # Use shared brew utilities for installation with conflict resolution
        if install_brewfile_with_conflicts "$brewfile"; then
            log_success "Core packages installed from $brewfile"
        fi

        # Install Mac App Store apps using shared utilities
        install_mas_apps "install/Brewfile.mas"
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
    if [[ -f "install/macOS/macOS.sh" ]]; then
        log_info "Applying macOS settings..."
        if ! ./install/macOS/macOS.sh; then
            log_warning "macOS settings application failed, continuing..."
        else
            log_success "macOS settings applied"
        fi
    fi
}

# Import iTerm2 settings
import_iterm2_settings() {
    # Check if iTerm2 is installed and the import script exists
    if [[ ! -f "iterm2/manage-iterm2.sh" ]]; then
        log_info "iTerm2 management script not found, skipping..."
        return 0
    fi

    # Check if iTerm2 settings file exists in dotfiles
    if [[ ! -f "iterm2/com.googlecode.iterm2.plist" ]]; then
        log_info "No iTerm2 settings in dotfiles, skipping import..."
        return 0
    fi

    # Ask user if they want to import iTerm2 settings
    if ask_yes_no "📱 Import iTerm2 profile settings?" "y"; then
        log_info "Importing iTerm2 settings..."

        # Make script executable if it isn't
        chmod +x iterm2/manage-iterm2.sh

        if ./iterm2/manage-iterm2.sh import; then
            log_success "iTerm2 settings imported successfully"
            log_info "💡 Restart iTerm2 for all changes to take effect"
        else
            log_warning "iTerm2 settings import failed, continuing..."
        fi
    else
        log_info "Skipping iTerm2 settings import"
        log_info "💡 You can manually import later with: ./iterm2/manage-iterm2.sh import"
    fi
}

# Create symlinks
create_symlinks() {
    log_info "Creating symlinks..."

    # Add rollback to clean symlinks if needed
    add_rollback 'make clean &> /dev/null || true'

    if ! ./scripts/symlink.sh; then
        log_error "Failed to create symlinks"
        exit 1
    fi
    log_success "Symlinks created successfully"
}

# Configure shell settings
configure_shell_settings() {
    log_info "Configuring shell settings..."

    # Create .hushlogin to suppress login messages
    touch ~/.hushlogin

    log_success "Shell settings configured"
}

# Make scripts executable
make_scripts_executable() {
    log_info "Making scripts executable..."
    find . -name "*.sh" -exec chmod +x {} \;
    chmod +x scripts/symlink.sh scripts/shellcheck.sh
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

    # Change to dotfiles root directory
    cd "$(dirname "$0")/.."

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
        # Note: Using znap instead of Oh My Zsh - no need to install Oh My Zsh
    fi

    # Neovim configuration is now handled automatically via symlinks

    # Always try rust and macOS settings (they check internally)
    install_rust
    install_macos_settings
    import_iterm2_settings

    # Create symlinks
    if [[ "$CREATE_SYMLINKS" == true ]]; then
        create_symlinks
    fi

    # Configure shell settings
    configure_shell_settings

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

    if [[ "$ENABLE_ANALYTICS" == true ]]; then
        echo "  4. Try 'make analytics' to see package usage and performance insights"
    fi
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
    echo "  --simple            Simple setup without analytics or advanced features"
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
        --simple)
            # Simple setup - disable analytics and complex features
            ENABLE_ANALYTICS=false
            INTERACTIVE_MODE=false
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
    cd "$(dirname "$0")/.."
    check_macos
    install_homebrew
    install_packages
elif [[ "$SYMLINK_ONLY" == true ]]; then
    log_info "Creating symlinks only..."
    cd "$(dirname "$0")/.."
    create_symlinks
elif [[ "$DEPS_ONLY" == true ]]; then
    log_info "Checking dependencies only..."
    cd "$(dirname "$0")/.."
    ./scripts/check-deps.sh
else
    # Run full installation
    main
fi
