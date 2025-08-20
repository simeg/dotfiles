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

# Test suite configurations (Bats)
BATS_TESTS_DIR := ./tests/bats
TEST_COMPREHENSIVE := $(BATS_TESTS_DIR)/test_comprehensive.bats
TEST_CI := $(BATS_TESTS_DIR)/test_ci.bats
TEST_ADVANCED := $(BATS_TESTS_DIR)/test_advanced_config.bats
TEST_PERFORMANCE := $(BATS_TESTS_DIR)/test_performance.bats
TEST_SECURITY := $(BATS_TESTS_DIR)/test_security.bats
TEST_CONFIG := $(BATS_TESTS_DIR)/test_configuration.bats
TEST_INTEGRATION := $(TESTS_DIR)/test_integration_local.sh

# Analytics and monitoring scripts
ANALYTICS_PACKAGE := $(SCRIPTS_DIR)/analyze-package-usage.sh
ANALYTICS_PERFORMANCE := $(SCRIPTS_DIR)/performance-report.sh
ANALYTICS_ENHANCED := $(SCRIPTS_DIR)/enhanced-analytics.sh
MONITOR_HEALTH := $(SCRIPTS_DIR)/health-check.sh
MONITOR_SYSTEM := $(BIN_DIR)/system-monitor
PROFILE_SHELL := $(SCRIPTS_DIR)/profile-shell.sh

# Use GNU utils if available, otherwise macOS
FIND := $(shell command -v gfind >/dev/null 2>&1 && echo gfind || echo find)
SED  := $(shell command -v gsed  >/dev/null 2>&1 && echo gsed  || echo sed)

# Common conditional checks
check_brew := command -v brew >/dev/null 2>&1
check_mas := command -v mas >/dev/null 2>&1

# Define all phony targets (targets that don't create files)
.PHONY: all setup setup-minimal update validate test test-ci test-advanced lint clean packages deps health help \
        health-monitor health-analytics health-profile snapshot fix-whitespace lint-whitespace symlink

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
	@echo "  test               Run local test suite (safe, non-destructive)"
	@echo "  test-ci            Run CI test suite (includes destructive tests)"
	@echo "  test-advanced      Advanced tests (performance + security)"
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
	@echo "Maintenance & Utilities:"
	@echo "  fix-whitespace     Remove trailing whitespace from all files"
	@echo "  lint-whitespace    Check for trailing whitespace in files"
	@echo "  symlink            Create symbolic links (run as part of setup)"
	@echo ""
	@echo "Advanced Usage Examples:"
	@echo "  make test               # Local test suite (safe, non-destructive)"
	@echo "  make test-ci            # CI test suite (includes destructive tests)"
	@echo "  make test-advanced      # Advanced tests (performance + security)"
	@echo "  make health-monitor     # Real-time system monitoring dashboard"
	@echo "  make health-analytics   # Package usage and performance analytics"
	@echo "  make health-profile     # Shell startup performance profiling"
	@echo "  make snapshot           # Take system metrics snapshot"
	@echo "  make setup-minimal      # Essential setup only (faster)"
	@echo "  make fix-whitespace     # Remove trailing whitespace from all files"
	@echo ""
	@echo "Development & CI:"
	@echo "  make test-ci            # Run destructive tests (use in CI only)"

# =============================================================================
# CORE TARGETS
# =============================================================================

# Complete setup process for new dotfiles installation
setup:
	@echo "🚀 Starting complete dotfiles setup..."
	@$(SCRIPTS_DIR)/setup.sh

# Minimal setup (essential only, faster)
setup-minimal:
	@echo "🔧 Running minimal setup (essential only)..."
	@DOTFILES_MINIMAL=true $(SCRIPTS_DIR)/setup.sh

# Update all components: git repos, packages, plugins, and configurations
update:
	@echo "🔄 Updating all dotfiles components..."
	@$(SCRIPTS_DIR)/update.sh

# Validate that all configurations are working correctly
validate:
	@echo "✅ Validating dotfiles configuration..."
	@$(SCRIPTS_DIR)/validate.sh

# Local test suite (excludes CI-only destructive tests)
test:
	@echo "🧪 Running local test suite with Bats..."
	@if command -v bats >/dev/null 2>&1; then \
		find $(BATS_TESTS_DIR) -name "*.bats" ! -name "*_ci.bats" -exec bats {} \;; \
	else \
		echo "❌ Bats not found. Install with: brew install bats-core"; \
		exit 1; \
	fi

# CI test suite including destructive tests (for CI environments)
test-ci:
	@echo "🧪 Running complete test suite (including CI-only tests)..."
	@if command -v bats >/dev/null 2>&1; then \
		bats $(BATS_TESTS_DIR); \
	else \
		echo "❌ Bats not found. Install with: brew install bats-core"; \
		exit 1; \
	fi

# Advanced test suite (configuration + performance + security)
test-advanced:
	@echo "🚀 Running advanced test suite..."
	@if command -v bats >/dev/null 2>&1; then \
		bats $(TEST_ADVANCED) $(TEST_PERFORMANCE) $(TEST_SECURITY); \
	else \
		echo "❌ Bats not found. Install with: brew install bats-core"; \
		exit 1; \
	fi



# Run shellcheck linting on all shell scripts
lint: lint-whitespace
	@echo "🔍 Running shellcheck on all shell scripts..."
	@$(SCRIPTS_DIR)/shellcheck.sh
	@echo "✅ Linting completed"

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
	@if [[ "$${CI:-false}" == "true" ]] || [[ -n "$${GITHUB_ACTIONS:-}" ]] || [[ "$${DOTFILES_CI:-false}" == "true" ]]; then \
		$(SCRIPTS_DIR)/check-deps.sh --core || (echo "⚠️  Some dependencies are missing. This is normal for new setups."; echo "💡 Run 'make packages' to install missing packages."); \
	else \
		$(SCRIPTS_DIR)/check-deps.sh || (echo "⚠️  Some dependencies are missing. This is normal for new setups."; echo "💡 Run 'make packages' to install missing packages."); \
	fi

# System health and diagnostics
health:
	@echo "🏥 Running comprehensive system health check..."
	@$(MONITOR_HEALTH)
	@echo ""
	@echo "💡 Tip: Use 'make health-monitor', 'make health-analytics', or 'make health-profile' for specialized diagnostics"

# Real-time system monitoring dashboard
health-monitor:
	@echo "📊 Starting real-time system monitoring dashboard..."
	@$(MONITOR_SYSTEM) dashboard

# Comprehensive analytics (package usage and performance)
health-analytics:
	@echo "📈 Running comprehensive analytics..."
	@echo "📊 Package Usage Analysis:"
	@$(ANALYTICS_PACKAGE) analyze || echo "⚠️  Package analytics require data collection (run commands first)"
	@echo ""
	@echo "⚡️ Performance Analysis:"
	@$(ANALYTICS_PERFORMANCE) comprehensive || echo "⚠️  Performance monitoring requires data collection"
	@echo ""
	@echo "🚀 Enhanced Analytics:"
	@$(ANALYTICS_ENHANCED) comprehensive

# Shell startup performance profiling
health-profile:
	@echo "📊 Profiling shell startup performance..."
	@$(PROFILE_SHELL)

# Take system metrics snapshot
snapshot:
	@echo "📸 Taking system metrics snapshot..."
	@$(MONITOR_SYSTEM) snapshot --quiet

# Correct -i syntax for BSD vs GNU sed
SED_INPLACE := -i ''
ifeq ($(shell $(SED) --version >/dev/null 2>&1 && echo gnu),gnu)
	  SED_INPLACE := -i''
	endif

# Removes all whitespace chars from files with these extensions
fix-whitespace:
	@echo "🧹 Removing trailing whitespace..."
	@$(FIND) . -type f \
	  \( -name "*.zsh" -o -name "*.yml" -o -name "*.yaml" -o -name "*.toml" -o \
	     -name "*.sh"  -o -name "*.md"  -o -name "*.lua"  -o -name "*.json" -o \
	     -name "*.bash" -o -name "*.bats" -o -name "*.txt" \) \
	  -not -path "./.git/*" \
	  -exec $(SED) $(SED_INPLACE) -e 's/[[:space:]]\{1,\}$$//' {} +
	@echo "✅ Done"

# Finds trailing whitespace chars
lint-whitespace:
	@echo "🔎 Checking for trailing whitespace..."
	@bad=$$($(FIND) . -type f \
	  \( -name "*.zsh" -o -name "*.yml" -o -name "*.yaml" -o -name "*.toml" -o \
	     -name "*.sh"  -o -name "*.md"  -o -name "*.lua"  -o -name "*.json" -o \
	     -name "*.bash" -o -name "*.bats" -o -name "*.txt" \) \
	  -not -path "./.git/*" \
	  -exec grep -nE '[[:blank:]]+$$' {} + || true); \
	if [ -n "$$bad" ]; then \
	  echo "$$bad"; \
	  echo "❌ Trailing whitespace detected"; \
	  exit 1; \
	else \
	  echo "✅ No trailing whitespace found"; \
	fi

# =============================================================================
# UTILITY TARGETS
# =============================================================================

symlink:
	@echo "🔗 Creating symbolic links..."
	@$(SCRIPTS_DIR)/symlink.sh
