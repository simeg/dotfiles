# My Dotfiles [![CI](https://github.com/simeg/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/simeg/dotfiles/actions/workflows/ci.yml) [![Test](https://github.com/simeg/dotfiles/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/simeg/dotfiles/actions/workflows/test.yml) [![Health Check](https://github.com/simeg/dotfiles/actions/workflows/health-check.yml/badge.svg?branch=main)](https://github.com/simeg/dotfiles/actions/workflows/health-check.yml)

These are my dotfiles. There are many like them, but these ones are mine. My dotfiles are my best friends. They are my life. I must master them as I master my life. My dotfiles, without me, are useless. Without my dotfiles, I am useless.

<img src="banner.png" alt="Dotfiles Banner" width="100%" style="display: block; margin: 0 auto;">


## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/simeg/dotfiles.git simeg-dotfiles
cd ~/simeg-dotfiles

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

### Setup & Installation
```bash
make setup                    # Complete initial setup
make install                  # Install packages only
make symlink                  # Create symlinks only
```

### Updates & Maintenance
```bash
make update                   # Update everything (git, packages, plugins)
make validate                 # Verify configuration is working
make health                   # Comprehensive system health check
make lint                     # Run shellcheck on all scripts
```

### Package & Analytics
```bash
make packages                 # Analyze and sync package usage
make analytics                # Comprehensive analytics (packages + performance)
make deps                     # Check all dependencies
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
│   │   └── completions/        # Tab completion scripts
│   ├── nvim/                   # Neovim configuration with Lazy.nvim (moved to .config/nvim/)
│   ├── starship/               # Starship prompt themes (moved to .config/starship/)
│   │   └── themes/             # Available starship themes
│   └── atuin/                  # Shell history sync configuration (moved to .config/atuin/)
├── bin/                        # Custom utility scripts
├── git/                        # Git configuration files
├── scripts/                    # Management and setup scripts
│   ├── install/                # Installation scripts
│   │   ├── Brewfile            # Homebrew packages
│   │   ├── brew.sh             # Homebrew installer
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
- **`gforbm`** - Git fetch and rebase from main branch
- **`git-show`** - Enhanced git show with formatting
- **`rssh`** - Remote SSH utilities
- **`spuri`** - Python script for special URI handling
- **`squash`** - Interactive Git commit squashing
- **`super-amend`** - Enhanced Git amend workflow
- **`starship-theme`** - Easy starship theme switcher
- **`smart-cat`** - Smart `cat` that uses `glow` for markdown files
- **`perf-dashboard`** - Performance monitoring dashboard

For detailed information about all available commands and targets, see the [Make Targets Documentation](docs/MAKE_TARGETS.md).

## 🎨 Shell Features

### Zsh Plugins (via znap)
- **Syntax highlighting** - Real-time command syntax highlighting
- **Auto-suggestions** - Fish-like command suggestions from history
- **History search** - Multi-word history search
- **Git integration** - Git aliases and status integration
- **macOS utilities** - macOS-specific helper functions

### Prompt (Starship)
- Fast and lightweight prompt with multiple themes
- Git status integration and detailed information
- Directory context and navigation indicators
- Performance metrics and command duration
- Easy theme switching with `starship-theme` command

## 🎨 Starship Theme Management

This repository includes multiple starship themes and a convenient theme switcher:

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

Themes are stored in `.config/starship/themes/` as `.toml` files. Each theme file should:
- Start with a descriptive comment (e.g., `# 🌟 Minimal Theme`)
- Be a valid starship configuration
- Include appropriate module settings

## 🔍 Validation & Troubleshooting

The `validate.sh` script checks:
- ✅ All symlinks are correctly created
- ✅ Required tools are installed
- ✅ Zsh plugins are loaded
- ✅ Git configuration is set
- ✅ Neovim configuration is working
- ✅ PATH includes custom bin directory

### Common Issues

**Symlinks not working?**
```bash
./scripts/symlink.sh  # Recreate symlinks
```

**Plugins not loading?**
```bash
./scripts/update.sh --zsh-only  # Update Zsh plugins
source ~/.zshrc                 # Reload configuration
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

This project is licensed under the MIT License - see the LICENSE.md file for details.

## 🔐 Private Configuration

For sensitive environment variables (API keys, project IDs, etc.), use the private config file:

### Setup Private Config
```bash
# Create private config file (not tracked by git)
touch ~/.config/zsh/private.zsh
chmod 600 ~/.config/zsh/private.zsh

# Add sensitive variables
echo 'export ANTHROPIC_VERTEX_PROJECT_ID="your-project-id"' >> ~/.config/zsh/private.zsh
echo 'export API_KEY="your-api-key"' >> ~/.config/zsh/private.zsh
```

The `.zshrc` automatically sources `~/.config/zsh/private.zsh` if it exists. This file should:
- **Never be committed** to version control
- Contain only sensitive environment variables
- Be created manually on each new machine during setup
- Be secured with proper file permissions: `chmod 600 ~/.config/zsh/private.zsh`

### Important Security Notes

⚠️ **CRITICAL**: The private configuration system is designed to keep sensitive data OUT of the repository:

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
