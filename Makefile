# Dotfiles Management Makefile
#
# This Makefile provides convenient targets for managing dotfiles installation,
# updates, testing, and maintenance. All targets are designed to be idempotent
# and safe to run multiple times.

# Define all phony targets (targets that don't create files)
.PHONY: all setup update validate test test-quick test-syntax test-ci ci \
        lint symlink clean install uninstall \
        health health-quick profile profile-startup \
        deps deps-essential deps-core \
        packages packages-analyze packages-export packages-update packages-install \
        analytics analytics-packages analytics-performance analytics-report \
        perf-dashboard perf-report \
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
	@echo "  test-quick         Run quick validation tests only"
	@echo "  test-syntax        Run syntax-only tests"
	@echo "  test-ci            Run CI-friendly tests (no symlink dependencies)"
	@echo "  ci                 Run full CI pipeline (lint + test-ci)"
	@echo ""
	@echo "System Health:"
	@echo "  health             Complete system health check"
	@echo "  health-quick       Quick health check (essential components only)"
	@echo "  profile            Profile shell startup performance"
	@echo "  profile-startup    Profile startup with detailed timing"
	@echo ""
	@echo "Package Management:"
	@echo "  packages           Sync and analyze package usage"
	@echo "  packages-analyze   Analyze differences between installed and configured packages"
	@echo "  packages-export    Export package lists for other package managers"
	@echo "  packages-update    Update Brewfile with missing packages"
	@echo "  packages-install   Install packages from Brewfile"
	@echo ""
	@echo "Dependency Management:"
	@echo "  deps               Check all dependencies"
	@echo "  deps-essential     Check essential dependencies only"
	@echo "  deps-core          Check core development dependencies"
	@echo ""
	@echo "Analytics & Performance:"
	@echo "  analytics          Run comprehensive analytics (packages + performance)"
	@echo "  analytics-packages Analyze package usage patterns"
	@echo "  analytics-performance Analyze shell and command performance"
	@echo "  analytics-report   Generate detailed analytics reports"
	@echo "  perf-dashboard     Show interactive performance dashboard"
	@echo "  perf-report        Generate comprehensive performance report"

# =============================================================================
# SETUP & INSTALLATION
# =============================================================================

# Complete setup process for new dotfiles installation
# Includes: symlinks, package installation, and validation
setup:
	@echo "🚀 Starting complete dotfiles setup..."
	./scripts/setup.sh

# Install packages and dependencies from Brewfile
install: packages-install

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

# Run quick validation tests only (faster feedback)
test-quick:
	@echo "⚡ Running quick validation tests..."
	./scripts/tests/test_dotfiles.sh --quick

# Run syntax-only tests (no execution, fastest option)
test-syntax:
	@echo "📝 Running syntax-only tests..."
	./scripts/tests/test_dotfiles.sh --syntax-only

# Run CI-friendly tests (no symlink dependencies)
test-ci:
	@echo "🤖 Running CI-compatible tests..."
	./scripts/tests/test_ci.sh

# Complete CI pipeline: linting + testing
ci: lint test-ci
	@echo "✅ CI pipeline completed successfully"

# =============================================================================
# SYSTEM HEALTH & DIAGNOSTICS
# =============================================================================

# Comprehensive system health check
health:
	@echo "🏥 Running comprehensive system health check..."
	./scripts/health-check.sh

# Quick health check for essential components only
health-quick:
	@echo "⚡ Running quick health check..."
	./scripts/health-check.sh --quick

# Profile shell startup performance with detailed analysis
profile:
	@echo "📊 Profiling shell startup performance..."
	./scripts/profile-shell.sh

# Profile startup timing with granular measurements
profile-startup:
	@echo "⏱️  Profiling startup timing..."
	./scripts/profile-shell.sh --startup

# =============================================================================
# DEPENDENCY MANAGEMENT
# =============================================================================

# Check all dependencies are installed and properly configured
deps:
	@echo "🔧 Checking all dependencies..."
	./scripts/check-deps.sh

# Check only essential dependencies (minimal viable setup)
deps-essential:
	@echo "⚡ Checking essential dependencies..."
	./scripts/check-deps.sh --essential

# Check core development dependencies
deps-core:
	@echo "💻 Checking core development dependencies..."
	./scripts/check-deps.sh --core

# =============================================================================
# PACKAGE MANAGEMENT
# =============================================================================

# Comprehensive package synchronization and analysis
packages: packages-analyze

# Analyze differences between installed packages and Brewfile
packages-analyze:
	@echo "📦 Analyzing package differences..."
	./scripts/sync-packages.sh analyze

# Export package lists for other package managers (npm, pipx, etc.)
packages-export:
	@echo "📤 Exporting package lists..."
	./scripts/sync-packages.sh export

# Update Brewfile with currently installed but missing packages
packages-update:
	@echo "🔄 Updating Brewfile with missing packages..."
	./scripts/sync-packages.sh update

# Install packages from Brewfile
packages-install:
	@echo "📥 Installing packages from Brewfile..."
	@if command -v brew >/dev/null 2>&1; then \
		brew bundle --file=install/Brewfile; \
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
	@echo "⚡ Performance Dashboard:"
	@./bin/perf-dashboard || echo "⚠️  Performance monitoring requires data collection"

# Analyze package usage patterns and identify optimization opportunities
analytics-packages:
	@echo "📦 Analyzing package usage patterns..."
	./scripts/analyze-package-usage.sh analyze

# Analyze shell and command performance metrics
analytics-performance:
	@echo "⚡ Analyzing performance metrics..."
	./scripts/performance-report.sh comprehensive

# Generate comprehensive analytics reports for detailed review
analytics-report:
	@echo "📊 Generating comprehensive analytics reports..."
	@echo "📦 Package Usage Report:"
	@./scripts/analyze-package-usage.sh report
	@echo "⚡ Performance Report:"
	@./scripts/performance-report.sh export
	@echo "✅ Reports generated in home directory"

# Show interactive performance dashboard with real-time metrics
perf-dashboard:
	@echo "📊 Opening performance dashboard..."
	./bin/perf-dashboard

# Generate detailed performance analysis report
perf-report:
	@echo "📈 Generating performance analysis report..."
	./scripts/performance-report.sh comprehensive

