# Shell Environment Management

## Overview
Comprehensive Zsh shell environment with modular configuration, plugin management via znap, and performance monitoring. Provides enhanced CLI experience with intelligent aliases, functions, and completions.

## How It Works
- **Modular Configuration**: Core configuration split across multiple files for maintainability
- **Plugin Management**: Uses znap (lightweight alternative to oh-my-zsh) for plugin loading
- **Performance Tracking**: Built-in shell startup performance monitoring
- **Lazy Loading**: Optimized loading of heavy tools to improve startup time

## Key Files

### Core Configuration
- `.config/zsh/.zshrc` - Main shell configuration entry point
- `.config/zsh/.znap-plugins.zsh` - Plugin definitions and configuration
- `.config/zsh/aliases.zsh` - Comprehensive command aliases
- `.config/zsh/functions.zsh` - Custom shell functions
- `.config/zsh/exports.zsh` - Environment variable exports
- `.config/zsh/path.zsh` - PATH management
- `.config/zsh/misc.zsh` - Miscellaneous settings

### Performance & Optimization
- `.config/zsh/lazy-loading.zsh` - Lazy loading of heavy tools (Docker, Maven, etc.)
- `.config/zsh/completions.zsh` - Tab completion configuration
- `.config/zsh/completions/` - Custom completion scripts

### Private Configuration
- `.config/zsh/private.zsh` - Machine-specific settings (not tracked in git)

## Key Features

### Plugin Management
- **znap**: Lightweight plugin manager with automatic installation
- **Plugins**: git, syntax highlighting, autosuggestions, and more
- **Plugin file**: Centralized plugin configuration in `.znap-plugins.zsh`

### Smart Aliases
- **Editor**: `vim`/`vi`/`v` → `nvim`, quick config access (`vimrc`, `zshrc`)
- **CLI Tools**: `cat` → `smart-cat` (markdown rendering), `ls` → `eza`
- **Development**: Quick access to common files (`vm` for Makefile, `vp` for package.json)
- **Navigation**: Enhanced directory operations with verbose output

### Performance Optimization
- **Lazy Loading**: Heavy tools loaded only when needed
- **Startup Monitoring**: Tracks shell initialization time
- **Modular Loading**: Only loads configuration files that exist

### Tab Completion
- **Smart Completions**: Context-aware completions for custom tools
- **starship-theme**: Dynamic theme name completion
- **Git**: Enhanced git command completions

## Integration Points
- **Starship Prompt**: Shell integrates with Starship prompt themes
- **Neovim**: Tight integration with Neovim configuration
- **Git**: Enhanced git workflow aliases and functions
- **Development Tools**: Aliases for common development tasks

## Performance Monitoring
The shell tracks startup performance and can generate reports via:
- `make health-profile` - Profile shell startup
- `./scripts/performance-report.sh` - Detailed performance analysis