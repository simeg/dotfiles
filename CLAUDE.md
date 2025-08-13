# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Primary Commands (via Makefile)
```bash
make setup                 # Complete initial setup for new installations
make update                # Update all components (git, packages, plugins)
make validate              # Verify configuration is working
make lint                  # Run shellcheck on all shell scripts
make test                  # Run complete test suite
make health                # Comprehensive system health check
make deps                  # Check all dependencies
make packages              # Analyze and sync package usage
make analytics             # Run comprehensive analytics (packages + performance)
make analytics-enhanced    # Run enhanced analytics (productivity + frequency + optimization)
make profile               # Profile shell startup performance
```

### Direct Script Usage
```bash
./scripts/setup.sh --help     # See all setup options
./scripts/validate.sh --zsh   # Validate only Zsh configuration
./scripts/update.sh --brew-only  # Update only Homebrew packages
```

## Architecture Overview

### Core Structure
This is a macOS dotfiles repository built around automation and modularity:

- **Shell Environment**: Zsh with znap plugin manager and Starship prompt
- **Editor**: Neovim with Lazy.nvim plugin manager (Lua-based configuration)  
- **Package Management**: Homebrew with comprehensive Brewfile
- **Automation**: Extensive shell scripts for setup, maintenance, and monitoring

### Key Technologies
- **Zsh + znap**: Lightweight plugin management (not oh-my-zsh)
- **Neovim + Lazy.nvim**: Modern vim replacement with Lua configuration
- **Starship**: Cross-shell prompt with multiple themes in `starship/themes/`
- **Homebrew**: Primary package manager with Bundle support
- **Analytics System**: Built-in package usage and performance monitoring

### Configuration Organization
```
.config/
├── zsh/               # Modular shell configuration (aliases, exports, functions)
├── nvim/              # Neovim configuration with core/ and plugins/ structure  
├── starship/themes/   # Multiple prompt themes (.toml files)
├── atuin/             # Shell history sync configuration
└── completions/       # Tab completion scripts
bin/                   # Custom utility scripts (smart-cat, git helpers, etc.)
git/                   # Git configuration files
install/Brewfile       # Comprehensive package definitions
```

### Script Architecture
- **Main Scripts**: `setup.sh`, `update.sh`, `validate.sh`, `symlink.sh`
- **Installation Scripts**: `scripts/install/` (brew.sh, zsh.sh, etc.)
- **Testing**: `scripts/tests/` with CI-compatible test suite
- **Analytics**: Built-in monitoring of package usage and shell performance

### Neovim Configuration Pattern
- `init.lua`: Entry point loading core settings and plugins
- `core/`: Basic vim settings (options, keymaps, autocmds)
- `plugins/`: Individual plugin configurations loaded by lazy.nvim
- Modular approach with separate files for LSP, completion, git integration

### Analytics & Performance Monitoring
- Package usage tracking to identify unused tools
- Shell startup performance monitoring  
- Interactive dashboard with real-time metrics
- Automatic optimization suggestions based on usage patterns

## Development Patterns

### Tool Aliases & Preferences
- `nvim` preferred over `vim` (aliased)
- `eza` instead of `ls` (modern replacement)
- `smart-cat` instead of `cat` (uses glow for markdown)
- `kubecolor` instead of plain `kubectl`
- `mvnd` instead of `mvn` (faster Maven daemon)

### Private Configuration
- Sensitive data goes in `~/.config/zsh/private.zsh` (not tracked by git)
- Automatic sourcing if file exists
- Machine-specific setup required for each new computer

### Safety Features
- Automatic backup of existing dotfiles during setup
- Interactive setup mode with configuration options
- Validation scripts to verify proper installation
- Clean uninstall capability

### Tab Completion
Smart tab completion is available for key scripts:
- `starship-theme <TAB>` - Shows commands (list, set, current, preview, etc.)
- `starship-theme set <TAB>` - Shows available theme names dynamically
- Completion files located in `.config/zsh/completions/` and symlinked to `~/.config/zsh/completions/`

## Major Features

This dotfiles repository includes 8 major feature areas, each with comprehensive documentation:

### 1. Shell Environment Management
**File**: [`docs/development/features/SHELL_ENVIRONMENT.md`](docs/development/features/SHELL_ENVIRONMENT.md)  
**Summary**: Modular Zsh configuration with znap plugin management, performance monitoring, and intelligent aliases

### 2. Neovim Configuration  
**File**: [`docs/development/features/NEOVIM_CONFIGURATION.md`](docs/development/features/NEOVIM_CONFIGURATION.md)  
**Summary**: Modern Lua-based Neovim setup with LSP, completion, and lazy-loaded plugins

### 3. Starship Prompt System
**File**: [`docs/development/features/STARSHIP_PROMPT.md`](docs/development/features/STARSHIP_PROMPT.md)  
**Summary**: Cross-shell prompt with multiple themes and dynamic switching capabilities

### 4. Package Management System
**File**: [`docs/development/features/PACKAGE_MANAGEMENT.md`](docs/development/features/PACKAGE_MANAGEMENT.md)  
**Summary**: Homebrew-based package management with usage analysis and synchronization

### 5. Analytics and Performance Monitoring
**File**: [`docs/development/features/ANALYTICS_MONITORING.md`](docs/development/features/ANALYTICS_MONITORING.md)  
**Summary**: Comprehensive system for monitoring package usage, shell performance, and optimization

### 6. Automation and Setup System
**File**: [`docs/development/features/AUTOMATION_SETUP.md`](docs/development/features/AUTOMATION_SETUP.md)  
**Summary**: Idempotent setup scripts with error handling, rollback, and validation capabilities

### 7. Git Integration and Workflow
**File**: [`docs/development/features/GIT_INTEGRATION.md`](docs/development/features/GIT_INTEGRATION.md)  
**Summary**: Enhanced Git configuration with Delta diffs, comprehensive aliases, and workflow tools

### 8. Custom Utilities and Bin Tools
**File**: [`docs/development/features/CUSTOM_UTILITIES.md`](docs/development/features/CUSTOM_UTILITIES.md)  
**Summary**: Collection of custom command-line tools for file operations, Git workflow, and productivity