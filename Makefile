# Dotfiles Management Makefile
#
# This Makefile provides convenient targets for managing dotfiles installation,
# updates, testing, and maintenance. All targets are designed to be idempotent
# and safe to run multiple times.

# Define all phony targets (targets that don't create files)
.PHONY: all setup update validate test test-ci test-integration ci \
        lint symlink clean install uninstall \
        health profile \
        deps \
        packages \
        analytics analytics-enhanced \
        help

# =============================================================================
# MAIN TARGETS
# =============================================================================

# Default target - runs complete setup for new installations
all: setup

# Show help information about available targets
help:
	@echo "Dotfiles Management Commands"
	@echo "============================"
	@echo ""
	@echo "Setup & Installation:"
	@echo "  setup              Complete dotfiles setup (symlinks, packages, validation)"
	@echo "  install            Install packages and dependencies"
	@echo "  uninstall          Remove symlinks and clean up"
	@echo "  symlink            Create symbolic links only"
	@echo ""
	@echo "Updates & Maintenance:"
	@echo "  update             Update all components (git, packages, plugins)"
	@echo "  validate           Verify all configurations are working correctly"
	@echo "  clean              Remove broken symlinks and temporary files"
	@echo ""
	@echo "Quality Assurance:"
	@echo "  lint               Run shellcheck on all shell scripts"
	@echo "  test               Run complete test suite"
	@echo "  test-ci            Run CI-friendly tests (no symlink dependencies)"
	@echo "  test-integration   Run full integration test (temporarily modifies config, should only be run on CI)"
	@echo "  ci                 Run full CI pipeline (lint + test-ci)"
	@echo ""
	@echo "System Health:"
	@echo "  health             Complete system health check"
	@echo "  profile            Profile shell startup performance"
	@echo "  deps               Check all dependencies"
	@echo ""
	@echo "Package Management:"
	@echo "  packages           Analyze and sync package usage"
	@echo ""
	@echo "Analytics & Performance:"
	@echo "  analytics          Run comprehensive analytics (packages + performance)"
	@echo "  analytics-enhanced Run enhanced analytics (productivity + frequency + optimization)"

# =============================================================================
# SETUP & INSTALLATION
# =============================================================================

# Complete setup process for new dotfiles installation
# Includes: symlinks, package installation, and validation
setup:
	@echo "🚀 Starting complete dotfiles setup..."
	./scripts/setup.sh

# Install packages and dependencies from Brewfile
install: packages

# Remove symlinks and perform cleanup
uninstall: clean
	@echo "🗑️  Uninstalling dotfiles..."
	@echo "Note: This removes symlinks but preserves your original files"

# Create symbolic links from dotfiles to home directory
symlink:
	@echo "🔗 Creating symbolic links..."
	./scripts/symlink.sh

# =============================================================================
# UPDATES & MAINTENANCE
# =============================================================================

# Update all components: git repos, packages, plugins, and configurations
update:
	@echo "🔄 Updating all dotfiles components..."
	./scripts/update.sh

# Validate that all configurations are working correctly
validate:
	@echo "✅ Validating dotfiles configuration..."
	./scripts/validate.sh

# Clean up broken symlinks, temporary files, and caches
clean:
	@echo "🧹 Cleaning up broken symlinks and temporary files..."
	@echo "Removing broken symlinks..."
	@find $$HOME -maxdepth 1 -type l ! -exec test -e {} \; -delete 2>/dev/null || true
	@echo "Removing dotfiles symlinks..."
	@rm -f ~/.zshrc ~/.znap-plugins.zsh ~/.gitconfig ~/.gitignore ~/.ideavimrc ~/.bin
	@rm -f ~/.config/nvim ~/.config/starship ~/.config/atuin
	@rm -f ~/.config/zsh/aliases.zsh ~/.config/zsh/exports.zsh ~/.config/zsh/functions.zsh ~/.config/zsh/misc.zsh ~/.config/zsh/path.zsh ~/.config/zsh/completions
	@echo "Cleanup completed. If things broke, run 'make symlink'"

# =============================================================================
# QUALITY ASSURANCE
# =============================================================================

# Run shellcheck linting on all shell scripts
lint:
	@echo "🔍 Running shellcheck on all shell scripts..."
	./scripts/shellcheck.sh

# Run complete test suite including integration tests
test:
	@echo "🧪 Running complete test suite..."
	./scripts/tests/test_dotfiles.sh


# Run CI-friendly tests (no symlink dependencies)
test-ci:
	@echo "🤖 Running CI-compatible tests..."
	./scripts/tests/test_ci.sh

# Complete CI pipeline: linting + testing
ci: lint test-ci
	@echo "✅ CI pipeline completed successfully"

# Run integration tests (same as CI but locally)
test-integration:
	@echo "🧪 Running integration tests locally..."
	@echo "⚠️  This will modify your dotfiles configuration temporarily"
	@echo "Press Ctrl+C within 5 seconds to cancel..."
	@sleep 5
	@echo "🚀 Starting integration test..."
	./scripts/tests/test_integration_local.sh

# =============================================================================
# SYSTEM HEALTH & DIAGNOSTICS
# =============================================================================

# Comprehensive system health check
health:
	@echo "🏥 Running comprehensive system health check..."
	./scripts/health-check.sh

# Profile shell startup performance with detailed analysis
profile:
	@echo "📊 Profiling shell startup performance..."
	./scripts/profile-shell.sh

# =============================================================================
# DEPENDENCY MANAGEMENT
# =============================================================================

# Check all dependencies are installed and properly configured
deps:
	@echo "🔧 Checking all dependencies..."
	./scripts/check-deps.sh

# =============================================================================
# PACKAGE MANAGEMENT
# =============================================================================

# Comprehensive package management: analyze, sync, and install
packages:
	@echo "📦 Managing packages..."
	@echo "📊 Analyzing package differences..."
	@./scripts/sync-packages.sh analyze
	@echo "📥 Installing packages from Brewfile..."
	@if command -v brew >/dev/null 2>&1; then \
		brew bundle --file=install/Brewfile; \
		if [[ -f install/Brewfile.mas ]] && command -v mas >/dev/null 2>&1; then \
			echo "📱 Installing Mac App Store apps..."; \
			brew bundle --file=install/Brewfile.mas; \
		else \
			echo "⚠️  Skipping Mac App Store apps (mas not found or Brewfile.mas missing)"; \
		fi; \
	else \
		echo "❌ Homebrew not found. Please install Homebrew first."; \
		exit 1; \
	fi

# =============================================================================
# ANALYTICS & PERFORMANCE MONITORING
# =============================================================================

# Run comprehensive analytics (both package usage and performance)
analytics:
	@echo "🔍 Running comprehensive analytics..."
	@echo "📊 Package Usage Analysis:"
	@./scripts/analyze-package-usage.sh analyze || echo "⚠️  Package analytics require data collection (run commands first)"
	@echo ""
	@echo "⚡ Performance Analysis:"
	@./scripts/performance-report.sh comprehensive || echo "⚠️  Performance monitoring requires data collection"
	@echo ""
	@echo "📊 Opening performance dashboard..."
	@./bin/perf-dashboard || echo "⚠️  Performance dashboard requires data collection"

# Run enhanced analytics with productivity metrics, command frequency, and predictive optimization
analytics-enhanced:
	@echo "🚀 Running enhanced analytics with productivity insights..."
	@./scripts/enhanced-analytics.sh comprehensive

