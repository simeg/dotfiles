# Dotfiles Management Makefile
#
# This Makefile provides convenient targets for managing dotfiles installation,
# updates, testing, and maintenance. All targets are designed to be idempotent
# and safe to run multiple times.

# =============================================================================
# VARIABLES & CONFIGURATION
# =============================================================================

# Common script paths to reduce duplication
SCRIPTS_DIR := ./scripts
TESTS_DIR := $(SCRIPTS_DIR)/tests
BIN_DIR := ./bin

# Brewfile paths
BREWFILE := install/Brewfile
BREWFILE_MAS := install/Brewfile.mas

# Test suite configurations
TEST_COMPREHENSIVE := $(TESTS_DIR)/test_comprehensive.sh
TEST_CI := $(TESTS_DIR)/test_ci.sh
TEST_ADVANCED := $(TESTS_DIR)/test_advanced.sh
TEST_INTEGRATION := $(TESTS_DIR)/test_integration_local.sh

# Analytics and monitoring scripts
ANALYTICS_PACKAGE := $(SCRIPTS_DIR)/analyze-package-usage.sh
ANALYTICS_PERFORMANCE := $(SCRIPTS_DIR)/performance-report.sh
ANALYTICS_ENHANCED := $(SCRIPTS_DIR)/enhanced-analytics.sh
MONITOR_HEALTH := $(SCRIPTS_DIR)/health-check.sh
MONITOR_SYSTEM := $(BIN_DIR)/system-monitor
PROFILE_SHELL := $(SCRIPTS_DIR)/profile-shell.sh

# Common conditional checks
check_brew := command -v brew >/dev/null 2>&1
check_mas := command -v mas >/dev/null 2>&1

# Define all phony targets (targets that don't create files)
.PHONY: all setup setup-minimal update validate test test-quick test-advanced test-ci lint clean packages deps health help \
        health-monitor health-analytics health-profile snapshot

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
	@echo "Essential Commands:"
	@echo "  setup              Complete dotfiles setup (symlinks, packages, validation)"
	@echo "  setup-minimal      Essential setup only (faster)"
	@echo "  update             Update all components (git, packages, plugins)"
	@echo "  validate           Verify all configurations are working correctly"
	@echo "  test               Run complete test suite"
	@echo "  test-quick         Quick validation tests only"
	@echo "  test-advanced      Advanced tests (performance + security)"
	@echo "  test-ci            CI-compatible tests (no symlink dependencies)"
	@echo "  packages           Install and sync packages from Brewfile"
	@echo "  health             System diagnostics and health checks"
	@echo "  health-monitor     Real-time system monitoring dashboard"
	@echo "  health-analytics   Package usage and performance analytics"
	@echo "  health-profile     Shell startup performance profiling"
	@echo "  snapshot           Take system metrics snapshot"
	@echo "  clean              Remove broken symlinks and temporary files"
	@echo "  deps               Check all dependencies are installed"
	@echo "  lint               Run shellcheck on all shell scripts"
	@echo "  help               Show this help message"
	@echo ""
	@echo "Advanced Usage Examples:"
	@echo "  make test-quick         # Quick validation tests only"
	@echo "  make test-advanced      # Advanced tests (performance + security)"
	@echo "  make test-ci            # CI-compatible tests (no symlink dependencies)"
	@echo "  make health-monitor     # Real-time system monitoring dashboard"
	@echo "  make health-analytics   # Package usage and performance analytics"
	@echo "  make health-profile     # Shell startup performance profiling"
	@echo "  make snapshot           # Take system metrics snapshot"
	@echo "  make setup-minimal      # Essential setup only (faster)"
	@echo ""
	@echo "Development & CI:"
	@echo "  DOTFILES_CI=true make test  # Force CI mode for integration tests"

# =============================================================================
# CORE TARGETS
# =============================================================================

# Complete setup process for new dotfiles installation
setup:
	@echo "🚀 Starting complete dotfiles setup..."
	$(SCRIPTS_DIR)/setup.sh

# Minimal setup (essential only, faster)
setup-minimal:
	@echo "🔧 Running minimal setup (essential only)..."
	DOTFILES_MINIMAL=true $(SCRIPTS_DIR)/setup.sh

# Update all components: git repos, packages, plugins, and configurations
update:
	@echo "🔄 Updating all dotfiles components..."
	$(SCRIPTS_DIR)/update.sh

# Validate that all configurations are working correctly
validate:
	@echo "✅ Validating dotfiles configuration..."
	$(SCRIPTS_DIR)/validate.sh

# Comprehensive test suite
test:
	@echo "🧪 Running complete test suite..."
	$(TEST_COMPREHENSIVE) full

# Quick validation tests
test-quick:
	@echo "⚡ Running quick validation tests..."
	$(TEST_COMPREHENSIVE) quick

# Advanced test suite (performance + security)
test-advanced:
	@echo "🚀 Running advanced test suite..."
	$(TEST_ADVANCED) all

# CI-compatible tests
test-ci:
	@echo "🤖 Running CI-compatible tests..."
	$(TEST_CI)
	@if [[ "$${CI:-false}" == "true" ]] || [[ -n "$${GITHUB_ACTIONS:-}" ]] || [[ "$${DOTFILES_CI:-false}" == "true" ]]; then \
		echo "🧪 Running integration tests in CI..."; \
		$(TEST_INTEGRATION); \
	fi

# Run shellcheck linting on all shell scripts
lint:
	@echo "🔍 Running shellcheck on all shell scripts..."
	$(SCRIPTS_DIR)/shellcheck.sh

# Clean up broken symlinks, temporary files, and caches
clean:
	@echo "🧹 Cleaning up broken symlinks and temporary files..."
	@echo "Removing broken symlinks..."
	@find $$HOME -maxdepth 1 -type l ! -exec test -e {} \; -delete 2>/dev/null || true
	@echo "Removing dotfiles symlinks..."
	@rm -f ~/.zshrc ~/.znap-plugins.zsh ~/.gitconfig ~/.gitignore ~/.ideavimrc ~/.bin
	@rm -f ~/.config/nvim ~/.config/starship ~/.config/atuin
	@rm -f ~/.config/zsh/aliases.zsh ~/.config/zsh/exports.zsh ~/.config/zsh/functions.zsh ~/.config/zsh/misc.zsh ~/.config/zsh/path.zsh ~/.config/zsh/completions
	@echo "Cleanup completed. If things broke, run 'make setup'"

# Comprehensive package management: analyze, sync, and install
packages:
	@echo "📦 Managing packages..."
	@echo "📊 Analyzing package differences..."
	@$(SCRIPTS_DIR)/sync-packages.sh analyze
	@echo "📥 Installing packages from Brewfile..."
	@if $(check_brew); then \
		brew bundle --file=$(BREWFILE); \
		if [[ -f $(BREWFILE_MAS) ]] && $(check_mas); then \
			echo "📱 Installing Mac App Store apps..."; \
			brew bundle --file=$(BREWFILE_MAS); \
		else \
			echo "⚠️  Skipping Mac App Store apps (mas not found or Brewfile.mas missing)"; \
		fi; \
	else \
		echo "❌ Homebrew not found. Please install Homebrew first."; \
		exit 1; \
	fi

# Check all dependencies are installed and properly configured
deps:
	@echo "🔧 Checking all dependencies..."
	$(SCRIPTS_DIR)/check-deps.sh

# System health and diagnostics
health:
	@echo "🏥 Running comprehensive system health check..."
	$(MONITOR_HEALTH)
	@echo ""
	@echo "💡 Tip: Use 'make health-monitor', 'make health-analytics', or 'make health-profile' for specialized diagnostics"

# Real-time system monitoring dashboard
health-monitor:
	@echo "📊 Starting real-time system monitoring dashboard..."
	$(MONITOR_SYSTEM) dashboard

# Comprehensive analytics (package usage and performance)
health-analytics:
	@echo "🔍 Running comprehensive analytics..."
	@echo "📊 Package Usage Analysis:"
	@$(ANALYTICS_PACKAGE) analyze || echo "⚠️  Package analytics require data collection (run commands first)"
	@echo ""
	@echo "⚡ Performance Analysis:"
	@$(ANALYTICS_PERFORMANCE) comprehensive || echo "⚠️  Performance monitoring requires data collection"
	@echo ""
	@echo "🚀 Enhanced Analytics:"
	@$(ANALYTICS_ENHANCED) comprehensive

# Shell startup performance profiling
health-profile:
	@echo "📊 Profiling shell startup performance..."
	$(PROFILE_SHELL)

# Take system metrics snapshot
snapshot:
	@echo "📸 Taking system metrics snapshot..."
	$(MONITOR_SYSTEM) snapshot

# =============================================================================
# LEGACY COMPATIBILITY TARGETS
# =============================================================================

install: packages

symlink:
	@echo "🔗 Creating symbolic links..."
	$(SCRIPTS_DIR)/symlink.sh

uninstall: clean

monitor:
	@$(MAKE) health-monitor

profile:
	@$(MAKE) health-profile

analytics:
	@$(MAKE) health-analytics