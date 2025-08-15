#!/usr/bin/env bash

# Local integration test script
# This performs the same tests as the GitHub Actions workflow but locally
# with proper backup and restore of your existing configuration

set -e

# Source shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=../lib/error-handling.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/error-handling.sh"

# Global variables
BACKUP_DIR="$HOME/.dotfiles-integration-test-backup-$$"
TEST_FAILED=false

# Cleanup function
cleanup_and_restore() {
    local exit_code=$?

    if [[ "$TEST_FAILED" == true ]]; then
        log_error "Integration test failed, restoring original configuration..."
    else
        log_info "Integration test completed, restoring original configuration..."
    fi

    # Remove any symlinks we created
    log_info "Removing test symlinks..."
    find "$HOME" -maxdepth 1 -type l -delete 2>/dev/null || true
    rm -rf ~/.config/nvim ~/.config/starship ~/.config/atuin ~/.config/zsh 2>/dev/null || true

    # Restore original configs if they existed
    if [[ -d "$BACKUP_DIR" ]]; then
        log_info "Restoring original configuration from backup..."

        [[ -f "$BACKUP_DIR/zshrc.backup" ]] && mv "$BACKUP_DIR/zshrc.backup" ~/.zshrc || true
        [[ -f "$BACKUP_DIR/gitconfig.backup" ]] && mv "$BACKUP_DIR/gitconfig.backup" ~/.gitconfig || true
        [[ -d "$BACKUP_DIR/config.backup" ]] && mv "$BACKUP_DIR/config.backup" ~/.config || true
        [[ -d "$BACKUP_DIR/zsh.backup" ]] && mv "$BACKUP_DIR/zsh.backup" ~/.zsh || true

        # Clean up backup directory
        rm -rf "$BACKUP_DIR"

        log_success "Original configuration restored"
    else
        log_info "No backup found, nothing to restore"
    fi

    if [[ "$TEST_FAILED" == true ]]; then
        exit 1
    fi

    exit $exit_code
}

# Set up error handling
trap 'TEST_FAILED=true; cleanup_and_restore' ERR
trap 'cleanup_and_restore' EXIT

# Create backup of existing configuration
backup_existing_config() {
    log_info "Creating backup of existing configuration..."

    mkdir -p "$BACKUP_DIR"

    # Backup existing configs if they exist
    [[ -f ~/.zshrc ]] && cp ~/.zshrc "$BACKUP_DIR/zshrc.backup" || true
    [[ -f ~/.gitconfig ]] && cp ~/.gitconfig "$BACKUP_DIR/gitconfig.backup" || true
    [[ -d ~/.config ]] && cp -r ~/.config "$BACKUP_DIR/config.backup" || true
    [[ -d ~/.zsh ]] && cp -r ~/.zsh "$BACKUP_DIR/zsh.backup" || true

    # Record what we backed up
    log_info "Backed up configuration to: $BACKUP_DIR"
    ls -la "$BACKUP_DIR/" 2>/dev/null || log_info "No existing configuration found to backup"
}

# Test complete setup
test_complete_setup() {
    log_info "🚀 Testing complete dotfiles setup..."

    # Change to dotfiles directory
    cd "$(dirname "$0")/../.."

    # Make scripts executable
    find scripts -name "*.sh" -exec chmod +x {} \;
    chmod +x bin/* 2>/dev/null || true

    # Run setup with timeout
    if command -v gtimeout >/dev/null 2>&1; then
        gtimeout 30m make setup
    elif command -v timeout >/dev/null 2>&1; then
        timeout 30m make setup
    else
        make setup
    fi

    log_success "Setup completed successfully"
}

# Validate installation
test_validation() {
    log_info "✅ Testing validation..."

    # Run the built-in validation
    make validate

    # Additional specific checks
    log_info "Checking symlinks..."
    test -L ~/.zshrc || { log_error "$HOME/.zshrc not symlinked"; return 1; }
    test -L ~/.gitconfig || { log_error "$HOME/.gitconfig not symlinked"; return 1; }
    test -L ~/.config/nvim || { log_error "$HOME/.config/nvim not symlinked"; return 1; }

    log_info "Checking tools are available..."
    command -v nvim || { log_error "nvim not found"; return 1; }
    command -v starship || { log_error "starship not found"; return 1; }
    command -v git || { log_error "git not found"; return 1; }

    log_success "Validation tests passed"
}

# Test shell functionality
test_shell_functionality() {
    log_info "🐚 Testing shell functionality..."

    # Test zsh loads without errors
    /bin/zsh -i -c 'echo "Zsh interactive shell loads successfully"' || {
        log_error "Zsh failed to load interactively"
        return 1
    }

    # Test starship prompt works
    starship prompt --path "$PWD" >/dev/null || {
        log_error "Starship prompt failed"
        return 1
    }

    # Test custom bin scripts
    ./bin/smart-cat README.md >/dev/null || {
        log_error "smart-cat failed"
        return 1
    }

    log_success "Shell functionality tests passed"
}

# Test theme switching
test_theme_switching() {
    log_info "🎨 Testing theme switching..."

    # Test theme listing
    ./bin/starship-theme list || {
        log_error "starship-theme list failed"
        return 1
    }

    # Test theme switching
    local original_theme
    original_theme=$(./bin/starship-theme current)
    log_info "Original theme: $original_theme"

    ./bin/starship-theme set minimal || {
        log_error "Failed to set minimal theme"
        return 1
    }

    local current_theme
    current_theme=$(./bin/starship-theme current)
    [[ "$current_theme" == "minimal" ]] || {
        log_error "Theme not switched correctly. Expected: minimal, Got: $current_theme"
        return 1
    }

    # Test backup and restore
    ./bin/starship-theme backup || {
        log_error "Theme backup failed"
        return 1
    }

    ./bin/starship-theme set rainbow || {
        log_error "Failed to set rainbow theme"
        return 1
    }

    ./bin/starship-theme restore || {
        log_error "Theme restore failed"
        return 1
    }

    log_success "Theme switching tests passed"
}

# Test update functionality
test_update_functionality() {
    log_info "🔄 Testing update functionality..."

    # Test update components individually (safer)
    ./scripts/update.sh --git-only || {
        log_error "Git-only update failed"
        return 1
    }

    ./scripts/update.sh --symlinks-only || {
        log_error "Symlinks-only update failed"
        return 1
    }

    # Test update with specific exclusions
    ./scripts/update.sh --no-brew --no-nvim || {
        log_error "Selective update failed"
        return 1
    }

    log_success "Update functionality tests passed"
}

# Test analytics and health
test_analytics_and_health() {
    log_info "📊 Testing analytics and health functionality..."

    # Test health check
    make health || {
        log_error "Health check failed"
        return 1
    }

    # Test analytics (should work even without data)
    ./scripts/analyze-package-usage.sh analyze || log_warning "Package analysis requires usage data"

    # Test performance monitoring setup
    test -f "$HOME/.config/dotfiles/perf-data.csv" || log_warning "Performance data file not created yet"

    log_success "Analytics and health tests completed"
}

# Test linting
test_linting() {
    log_info "🔍 Testing linting..."

    # Run linting
    make lint || {
        log_error "Linting failed"
        return 1
    }

    # Run comprehensive validation
    make validate || {
        log_error "Comprehensive validation failed"
        return 1
    }

    log_success "Linting tests passed"
}

# Performance regression test
test_performance() {
    log_info "⚡ Testing performance benchmarks..."

    # Test shell startup time
    local start_time end_time duration
    start_time=$(date +%s%3N)
    /bin/zsh -i -c 'exit'
    end_time=$(date +%s%3N)
    duration=$((end_time - start_time))

    log_info "Shell startup time: ${duration}ms"

    if [[ $duration -gt 2000 ]]; then
        log_warning "Shell startup slower than expected: ${duration}ms > 2000ms"
    else
        log_success "Shell startup performance acceptable: ${duration}ms"
    fi
}

# Test cleanup
test_cleanup() {
    log_info "🧹 Testing cleanup functionality..."

    # Test make clean
    make clean || {
        log_error "Make clean failed"
        return 1
    }

    # Verify symlinks were removed
    [[ ! -L ~/.zshrc ]] || {
        log_error "Symlinks not cleaned up properly"
        return 1
    }

    log_success "Cleanup functionality works"
}

# Main function
main() {
    log_info "🧪 Starting local integration tests..."
    log_warning "This will temporarily modify your dotfiles configuration"
    log_warning "Your original configuration will be backed up and restored"

    # Ask for confirmation
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Integration test cancelled"
        exit 0
    fi

    # Backup existing configuration
    backup_existing_config

    # Run tests
    test_complete_setup
    test_validation
    test_shell_functionality
    test_theme_switching
    test_update_functionality
    test_analytics_and_health
    test_linting
    test_performance
    test_cleanup

    log_success "🎉 All integration tests passed!"
    log_info "Your original configuration will be restored when the script exits"
}

# Run main function
main "$@"
