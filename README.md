# My Dotfiles [![CI](https://github.com/simeg/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/simeg/dotfiles/actions/workflows/ci.yml) [![Test](https://github.com/simeg/dotfiles/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/simeg/dotfiles/actions/workflows/test.yml) [![Integration Tests](https://github.com/simeg/dotfiles/actions/workflows/integration-test.yml/badge.svg?branch=main)](https://github.com/simeg/dotfiles/actions/workflows/integration-test.yml)

A modern, automation-first dotfiles repository that takes the pain out of
development environment setup. Built for macOS with comprehensive testing,
analytics, and zero-maintenance updates. Whether you're setting up a new
machine or keeping your existing setup optimized, this repository handles the
heavy lifting so you can focus on what matters: building great software.

<img src="banner.png" alt="Dotfiles Banner" width="100%" style="display: block; margin: 0 auto;">


## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/simeg/dotfiles.git dotfiles
cd dotfiles

# Run the complete setup
make setup

# Verify everything is working
make validate
```

## 📋 What's Included

- **Zsh Configuration** - Modern shell setup with znap plugin manager
- **Neovim Setup** - Modern Neovim configuration with Lazy.nvim
- **Git Configuration** - Optimized Git settings and aliases
- **Starship Prompt** - Fast and customizable shell prompt
- **Custom Scripts** - Useful bin scripts for development workflow
- **Homebrew Integration** - Automated package management

## 🛠 Management Commands

### Essential Commands
```bash
make setup                    # Complete dotfiles setup (symlinks, packages, validation)
make update                   # Update all components (git, packages, plugins)
make validate                 # Verify all configurations are working correctly
make test                     # Run complete test suite
make packages                 # Install and sync packages from Brewfile
make health                   # System diagnostics and health checks
make clean                    # Remove broken symlinks and temporary files
make deps                     # Check all dependencies are installed
make lint                     # Run shellcheck on all shell scripts
make help                     # Show all available commands
```

### Advanced Usage
```bash
# Test variants
make test                     # Run the local Bats test suite
make test-advanced            # Advanced tests (performance + security)
make test-ci                  # CI-compatible tests (no symlink dependencies)

# Health diagnostics
make health-monitor           # Real-time system monitoring dashboard
make health-analytics         # Package usage and performance analytics
make health-profile           # Shell startup performance profiling
make snapshot                 # Take system metrics snapshot

# Setup variants
make setup-minimal            # Essential setup only (faster)
make symlink                  # Create symlinks only
```

## 📁 Directory Structure

```
├── .config/                    # Configuration files (mirrors ~/.config structure)
│   ├── zsh/                    # Zsh configuration files (moved to .config/zsh/)
│   │   ├── .zshrc              # Main Zsh configuration
│   │   ├── .znap-plugins.zsh   # Plugin definitions
│   │   ├── aliases.zsh         # Command aliases
│   │   ├── exports.zsh         # Environment variables
│   │   ├── functions.zsh       # Custom functions
│   │   ├── misc.zsh            # Miscellaneous config
│   │   ├── path.zsh            # PATH modifications
│   │   ├── completions.zsh     # Tab completion setup
│   │   ├── lazy-loading.zsh    # Plugin lazy loading
│   │   └── completions/        # Tab completion scripts
│   ├── nvim/                   # Neovim configuration with Lazy.nvim (moved to .config/nvim/)
│   ├── starship/               # Starship prompt themes (moved to .config/starship/)
│   │   └── themes/             # Available starship themes
│   └── atuin/                  # Shell history sync configuration (moved to .config/atuin/)
├── bin/                        # Custom utility scripts
├── git/                        # Git configuration files
├── install/                    # Package installation files
│   ├── Brewfile                # Core Homebrew packages
│   ├── Brewfile.mas            # Mac App Store apps (auto-included, skipped in CI)
│   ├── Brewfile.ci-minimal     # Minimal packages for CI
│   └── macOS/                  # macOS-specific configurations
├── scripts/                    # Management and setup scripts
│   ├── install/                # Installation scripts
│   │   ├── brew.sh             # Homebrew installer
│   │   ├── rust.sh             # Rust toolchain installer
│   │   └── zsh.sh              # Zsh setup
│   ├── setup.sh                # Main setup script
│   ├── update.sh               # Update script
│   ├── validate.sh             # Configuration validator
│   └── symlink.sh              # Symlink creator
```

## 🔧 Custom Bin Scripts

Located in `bin/` directory, these scripts enhance your development workflow:

- **`backup`** - Backup utility
- **`cpwd`** - Copy current working directory to clipboard
- **`fixup`** - Interactive Git fixup commits
- **`gcl`** - Git clone utility
- **`gforbm`** - Git fetch and rebase from main branch
- **`git-show`** - Enhanced git show with formatting
- **`perf-dashboard`** - Performance monitoring dashboard
- **`rssh`** - Remote SSH utilities
- **`smart-cat`** - Smart `cat` that uses `glow` for markdown files
- **`spuri`** - Python script for special URI handling
- **`squash`** - Interactive Git commit squashing
- **`starship-theme`** - Easy starship theme switcher
- **`super-amend`** - Enhanced Git amend workflow
- **`system-monitor`** - Real-time system monitoring
- **`use-private-git`** - Private Git configuration utility

For detailed information about all available commands and targets, see the
[Make Targets Documentation](docs/MAKE_TARGETS.md).

## 🎨 Shell Features

### Zsh Plugins (via znap)
- **Syntax highlighting** - Real-time command syntax highlighting
- **Auto-suggestions** - Fish-like command suggestions from history
- **History search** - Enhanced history search with substring matching
- **History sync** - Cross-machine history sync with Atuin
- **Node.js management** - NVM with lazy loading for performance

### Prompt (Starship)
- Fast and lightweight prompt with multiple themes
- Git status integration and detailed information
- Directory context and navigation indicators
- Performance metrics and command duration
- Easy theme switching with `starship-theme` command

## 🎨 Starship Theme Management

This repository includes multiple starship themes and a convenient theme
switcher:

### Available Themes

See [theme folder](.config/starship/themes).

### Theme Commands

```bash
starship-theme list              # List all available themes
starship-theme current           # Show current active theme
starship-theme set minimal       # Switch to minimal theme
starship-theme preview enhanced  # Preview theme configuration
starship-theme backup            # Backup current configuration
starship-theme restore           # Restore from backup
```

### Adding Your Own Themes

```bash
# Add a new theme from an existing .toml file
starship-theme add mytheme ~/path/to/my-starship.toml

# Or manually copy to themes directory
cp my-theme.toml .config/starship/themes/
starship-theme set my-theme
```

### Theme Structure

Themes are stored in `.config/starship/themes/` as `.toml` files. Each theme
file should:
- Start with a descriptive comment (e.g., `# 🌟 Minimal Theme`)
- Be a valid starship configuration
- Include appropriate module settings

## 🧪 Testing & Validation

This dotfiles repository includes a comprehensive testing framework to ensure
configuration integrity, performance monitoring, and security compliance.

### Quick Testing

```bash
# Run the local Bats test suite
make test

# Pre-commit validation (syntax + configuration checks)
make lint

# Advanced tests (performance + security)
make test-advanced
```

### Advanced Testing Framework

The advanced testing system provides three categories of validation:

**🔧 Configuration Validation**
- Zsh modular configuration structure and syntax
- Neovim Lua configuration validation
- Git security settings and credential configuration
- Starship prompt theme validation
- Package management (Brewfile) validation

**⚡ Performance Regression Testing**
- Shell startup time monitoring with baseline tracking
- Memory usage regression detection
- Plugin load time analysis
- Automatic performance baseline creation

**🔒 Security Compliance Checks**
- Intelligent secrets scanning (avoids false positives)
- File permissions security validation
- Shell security configuration audit
- Git security protocol verification
- Dependency source security analysis

```bash
# Run all advanced tests (config + performance + security via Bats)
make test-advanced
```

### Common Issues

**Symlinks not working?**
```bash
./scripts/symlink.sh  # Recreate symlinks
```

**Plugins not loading?**
```bash
./scripts/update.sh --zsh-only   # Update Zsh plugins
source ~/.zshrc                  # Reload configuration
```

**Homebrew packages missing?**
```bash
./scripts/update.sh --brew-only  # Update packages
```

**Neovim plugins not working?**
```bash
./scripts/update.sh --nvim-only  # Update Neovim plugins
```


## 📝 License

This project is licensed under the MIT License - see the LICENSE file for
details.

## 🔐 Private Configuration

For sensitive environment variables (API keys, project IDs, etc.), use the
private config file:

### Setup Private Config
```bash
# Create private config file (not tracked by git)
touch ~/.config/zsh/private.zsh
chmod 600 ~/.config/zsh/private.zsh

# Add sensitive variables
echo 'export ANTHROPIC_VERTEX_PROJECT_ID="your-project-id"' >> ~/.config/zsh/private.zsh
echo 'export API_KEY="your-api-key"' >> ~/.config/zsh/private.zsh
```

The `.zshrc` automatically sources `~/.config/zsh/private.zsh` if it exists.
This file should:
- **Never be committed** to version control
- Contain only sensitive environment variables
- Be created manually on each new machine during setup
- Be secured with proper file permissions: `chmod 600 ~/.config/zsh/private.zsh`

### Important Security Notes

⚠️ **CRITICAL**: The private configuration system is designed to keep sensitive
data OUT of the repository:

1. **Private files are stored locally**: All sensitive configs live in `~/.config/zsh/` on your machine
2. **Automatic exclusion**: A `.gitignore` file in `~/.config/zsh/` prevents accidental commits
3. **Machine-specific setup**: You must create `private.zsh` on each new computer
4. **No cloud sync**: These files should NOT be synced to cloud storage or shared

### What Goes in Private Config

```bash
# ~/.config/zsh/private.zsh - Examples of what belongs here:
export ANTHROPIC_VERTEX_PROJECT_ID="your-project-id"
export OPENAI_API_KEY="your-api-key"
export AWS_ACCESS_KEY_ID="your-aws-key"
export GITHUB_TOKEN="your-github-token"
export DATABASE_URL="your-db-connection-string"

# Work-specific configurations
export WORK_EMAIL="your.work@company.com"
export COMPANY_VPN_CONFIG="/path/to/company/vpn"

# Personal API keys and tokens
export PERSONAL_GITHUB_TOKEN="your-personal-token"
export HOMEBREW_GITHUB_API_TOKEN="your-brew-token"
```

### Setting Up Private Config on New Machines

When you set up dotfiles on a new computer, remember to:

1. **Create the private config file**:
   ```bash
   touch ~/.config/zsh/private.zsh
   chmod 600 ~/.config/zsh/private.zsh
   ```

2. **Add your sensitive variables**:
   ```bash
   echo 'export YOUR_API_KEY="your-actual-key"' >> ~/.config/zsh/private.zsh
   ```

3. **Verify it's working**:
   ```bash
   source ~/.zshrc
   echo $YOUR_API_KEY  # Should show your key
   ```

4. **Confirm it's excluded from git**:
   ```bash
   git status  # private.zsh should NOT appear in untracked files
   ```
