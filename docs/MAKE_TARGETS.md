# Make Targets Reference

This document provides detailed explanations of all available `make` targets in the dotfiles repository. Each target is designed to be idempotent and safe to run multiple times.

## Quick Reference

```bash
make help                    # Show all available targets with brief descriptions
make setup                   # Complete setup for new installations (recommended starting point)
make update                  # Update all components
make validate                # Verify configuration is working
make test                    # Run complete test suite
make lint                    # Check code quality
make health                  # System health check
make deps                    # Check dependencies
make packages                # Manage packages
make analytics               # Comprehensive analytics and monitoring
```

## Setup & Installation

### `make setup`
**Purpose**: Complete dotfiles setup for new installations  
**What it does**:
- Creates all necessary symbolic links
- Installs packages from Brewfile via Homebrew
- Sets up shell configuration (Zsh with znap plugins)
- Configures Neovim with Lazy.nvim
- Validates the entire installation
- Creates backup of existing dotfiles before overwriting

**When to use**: First time setting up dotfiles on a new machine

### `make install`
**Purpose**: Install packages and dependencies  
**Alias for**: `make packages`  
**What it does**:
- Analyzes package differences between installed and configured
- Installs packages from Brewfile via Homebrew
- Checks for Homebrew installation first

**When to use**: When you need to install missing packages or after adding new packages to Brewfile

### `make symlink`
**Purpose**: Create symbolic links only  
**What it does**:
- Links dotfiles from repository to home directory locations
- Creates `~/.zshrc`, `~/.gitconfig`, `~/.config/nvim`, etc.
- Does NOT install packages or validate configuration

**When to use**: When you only need to recreate symlinks (e.g., after accidental deletion)

### `make uninstall`
**Purpose**: Remove dotfiles installation  
**Alias for**: `make clean`  
**What it does**:
- Removes all symbolic links created by the dotfiles
- Preserves your original configuration files
- Cleans up temporary files and broken symlinks

**When to use**: When you want to remove dotfiles and restore original system state

## Updates & Maintenance

### `make update`
**Purpose**: Update all dotfiles components  
**What it does**:
- Updates the dotfiles repository (git pull)
- Updates Homebrew packages (`brew update && brew upgrade`)
- Updates Zsh plugins via znap
- Updates Neovim plugins via Lazy.nvim
- Refreshes shell completions

**When to use**: Regular maintenance (weekly/monthly) to keep everything current

### `make validate`
**Purpose**: Verify all configurations are working  
**What it does**:
- Checks all symlinks are correctly created and pointing to valid files
- Verifies required tools are installed and accessible
- Tests Zsh configuration loads without errors
- Validates Git configuration is properly set
- Confirms Neovim configuration is functional
- Ensures PATH includes custom bin directory

**When to use**: After setup, updates, or when troubleshooting issues

### `make clean`
**Purpose**: Clean up broken symlinks and temporary files  
**What it does**:
- Removes broken symbolic links from home directory
- Removes all dotfiles-created symlinks
- Cleans up temporary files and caches
- Provides instructions for restoration if needed

**When to use**: When symlinks are broken or you want a fresh start

## Quality Assurance

### `make lint`
**Purpose**: Run code quality checks  
**What it does**:
- Runs shellcheck on all shell scripts
- Identifies syntax errors, best practice violations, and potential bugs
- Checks for POSIX compliance where applicable

**When to use**: Before committing changes or when developing new scripts

### `make test`
**Purpose**: Run complete test suite  
**What it does**:
- Executes comprehensive integration tests
- Tests all major functionality end-to-end
- Validates symlink creation, package installation, and configuration loading
- Includes performance regression tests

**When to use**: Before releasing changes or when validating major modifications

### `make test-ci`
**Purpose**: Run CI-friendly tests  
**What it does**:
- Executes tests compatible with Continuous Integration environments
- Avoids tests requiring symlink dependencies or system modifications
- Focuses on portable functionality

**When to use**: In GitHub Actions or other CI systems

### `make ci`
**Purpose**: Complete CI pipeline  
**Combines**: `make lint` + `make test-ci`  
**What it does**:
- Runs complete CI validation workflow
- Ensures code quality and CI compatibility

**When to use**: In CI/CD pipelines or for comprehensive pre-commit validation

## System Health & Diagnostics

### `make health`
**Purpose**: Comprehensive system health check  
**What it does**:
- Validates all dotfiles components are working correctly
- Checks system dependencies and their versions
- Verifies performance metrics are within acceptable ranges
- Tests integration between different tools and configurations
- Provides detailed PATH analysis showing exact non-existent directories and their sources
- Provides actionable recommendations for issues found

**When to use**: Regular system maintenance or when experiencing issues

### `make profile`
**Purpose**: Profile shell startup performance  
**What it does**:
- Measures shell startup time with detailed breakdown
- Identifies slow-loading plugins or configurations
- Provides optimization recommendations
- Tracks performance trends over time

**When to use**: When shell feels slow or for performance optimization

### `make deps`
**Purpose**: Check all dependencies  
**What it does**:
- Verifies all required tools are installed
- Checks versions meet minimum requirements
- Validates tool configurations are correct
- Reports missing or outdated dependencies

**When to use**: Troubleshooting missing functionality or after system updates

## Package Management

### `make packages`
**Purpose**: Comprehensive package management  
**What it does**:
- Analyzes differences between installed packages and Brewfile configuration
- Generates detailed reports of discrepancies
- Installs missing packages from Brewfile
- Updates existing packages to latest versions
- Identifies packages installed but not in Brewfile

**When to use**: Regular package maintenance, installing missing packages, or setting up new machine

## Analytics & Performance Monitoring

### `make analytics`
**Purpose**: Comprehensive analytics and performance monitoring  
**What it does**:
- Runs package usage analysis to identify optimization opportunities
- Analyzes command usage patterns and identifies unused packages
- Performs comprehensive performance analysis of shell and commands
- Opens interactive performance dashboard with real-time metrics
- Provides system performance insights and trends
- Generates actionable recommendations for improvements

**When to use**: Regular system optimization, usage analysis, and performance troubleshooting

## Common Workflows

### New Machine Setup
```bash
make setup          # Complete setup
make validate       # Verify everything works
make health         # Check system health
```

### Regular Maintenance
```bash
make update         # Update everything
make packages       # Sync packages
make analytics      # Review usage patterns
```

### Troubleshooting
```bash
make validate       # Check configuration
make health         # Diagnose issues
make deps           # Verify dependencies
make clean && make symlink  # Reset symlinks
```

### Development
```bash
make lint           # Check code quality
make test           # Full testing
make ci             # Complete CI pipeline
```

### Performance Optimization
```bash
make profile        # Check startup performance
make analytics      # Analyze trends and usage
```

## Target Summary

| Target | Purpose | Use Case |
|--------|---------|----------|
| `setup` | Complete initial setup | New machine setup |
| `update` | Update all components | Regular maintenance |
| `validate` | Verify configuration | Troubleshooting |
| `health` | System health check | Diagnostics |
| `deps` | Check dependencies | Troubleshooting |
| `packages` | Manage packages | Package maintenance |
| `analytics` | Performance analysis | Optimization |
| `test` | Run test suite | Development |
| `lint` | Code quality check | Development |
| `profile` | Performance profiling | Optimization |
| `clean` | Clean up files | Troubleshooting |
| `symlink` | Create links only | Quick fixes |