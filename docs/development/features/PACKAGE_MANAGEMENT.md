# Package Management System

## Overview
Comprehensive package management using Homebrew with automated synchronization, analysis, and optimization. Manages development tools, CLI utilities, and applications across macOS systems.

## How It Works
- **Homebrew Core**: Primary package manager using Brewfile configurations
- **Bundle Management**: Declarative package installation via `brew bundle`
- **Sync Analysis**: Compare installed packages with dotfiles configuration
- **Usage Analytics**: Track package usage to identify optimization opportunities
- **Multiple Brewfiles**: Separate configurations for different scenarios

## Key Files

### Package Definitions
- `install/Brewfile` - Main package configuration (comprehensive)
- `install/Brewfile.ci-minimal` - Minimal packages for CI environments
- `install/Brewfile.mas` - Mac App Store applications

### Management Scripts
- `scripts/sync-packages.sh` - Analyze and sync package differences
- `scripts/analyze-package-usage.sh` - Track package usage patterns
- `scripts/install/brew.sh` - Homebrew installation and setup

### Integration
- `Makefile` targets for package operations (`make packages`)

## Key Features

### Brewfile Management
- **Categorized Packages**: Organized by function (dev tools, CLI, apps)
- **Version Control**: Specific versions for stability when needed
- **Comments**: Detailed descriptions for package purposes
- **Multi-Architecture**: Support for Apple Silicon and Intel Macs

### Package Categories

#### Core Development Tools
- **Languages**: Node.js, Python, Go, Ruby, Lua, Java (multiple versions)
- **Version Control**: Git, GitHub CLI, git-filter-repo
- **Build Tools**: Maven, mvnd (daemon), SBT, Gradle
- **Package Managers**: npm, pip, cargo

#### CLI Enhancements
- **Modern Replacements**: `eza` (ls), `ripgrep` (grep), `fd` (find)
- **File Tools**: `tree`, `bat` (cat), `glow` (markdown)
- **System Tools**: `htop`, `neofetch`, `jq`, `yq`
- **Network**: `curl`, `wget`, `httpie`

#### Development Environments
- **Editors**: Neovim, VS Code
- **Containers**: Docker, Docker Compose
- **Cloud**: AWS CLI, kubectl, terraform
- **Databases**: PostgreSQL, Redis, SQLite

### Synchronization Features
- **Gap Analysis**: Identify packages installed but not in Brewfile
- **Missing Packages**: Find Brewfile entries not installed
- **Usage Tracking**: Monitor which packages are actually used
- **Optimization**: Suggestions for removing unused packages

### Analytics and Monitoring
- **Usage Patterns**: Track command frequency and usage
- **Installation Status**: Monitor package health and updates
- **Performance Impact**: Identify packages affecting shell startup
- **Cleanup Recommendations**: Suggest packages for removal

## Package Sync Tool

### Commands
- `./scripts/sync-packages.sh analyze` - Compare installed vs configured
- `./scripts/sync-packages.sh sync` - Update Brewfile with current packages
- `make packages` - Full package management workflow

### Features
- **Smart Detection**: Automatically discover package discrepancies
- **Category Organization**: Maintain package organization in Brewfile
- **Safety Checks**: Warn before making changes to package lists
- **Backup Creation**: Preserve existing configurations

## Package Analysis

### Usage Analytics
- **Command Tracking**: Monitor which CLI tools are used
- **Frequency Analysis**: Identify most/least used packages
- **Optimization Suggestions**: Recommend packages for removal
- **Performance Impact**: Track startup time impact

### Reports Generated
- **Installed vs Configured**: Gap analysis report
- **Usage Statistics**: Package usage frequency
- **Size Analysis**: Disk space usage by package
- **Dependency Mapping**: Package interdependencies

## CI/Development Environments

### Brewfile.ci-minimal
- **Essential Tools**: Only critical packages for CI
- **Fast Installation**: Minimal dependencies for quick setup
- **Core Functionality**: Basic development tools only

### Brewfile.mas
- **Mac App Store**: Applications requiring App Store installation
- **GUI Applications**: Desktop applications and utilities
- **System Integration**: Apps that integrate with macOS features

## Integration Points
- **Shell Environment**: Packages integrate with shell aliases and functions
- **Development Workflow**: Tools support common development tasks
- **System Health**: Package status monitored in health checks
- **Performance**: Package loading optimized in shell startup

## Maintenance Operations
- **Updates**: `make update` - Update all packages
- **Health Checks**: `make health` - Verify package integrity
- **Cleanup**: `brew cleanup` - Remove old versions
- **Analytics**: `make health-analytics` - Package usage analysis

## Advanced Features
- **Version Pinning**: Lock specific versions when stability required
- **Tap Management**: Custom Homebrew taps for specialized tools
- **Cask Applications**: GUI applications via Homebrew Cask
- **Service Management**: Homebrew services for background processes