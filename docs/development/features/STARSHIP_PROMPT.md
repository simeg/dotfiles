# Starship Prompt System

## Overview
Modern, cross-shell prompt system with multiple themes and dynamic switching capability. Provides rich information about git status, directory context, and system state while maintaining performance.

## How It Works
- **Cross-Shell**: Works with Zsh, Bash, Fish, and other shells
- **Theme System**: Multiple pre-configured themes for different use cases
- **Dynamic Switching**: Runtime theme switching without shell restart
- **Git Integration**: Rich git status information and branch display
- **Performance**: Optimized prompt rendering with minimal latency

## Key Files

### Theme Configurations
- `.config/starship/themes/minimal.toml` - Clean, essential information only
- `.config/starship/themes/super-minimal.toml` - Absolute bare minimum
- `.config/starship/themes/minimal-extended.toml` - Minimal with additional context
- `.config/starship/themes/simple.toml` - Basic but functional
- `.config/starship/themes/rainbow.toml` - Colorful, information-rich
- `.config/starship/themes/catppuccin.toml` - Matches Catppuccin colorscheme

### Management Tools
- `bin/starship-theme` - Theme switcher script with preview capability
- `.config/zsh/completions/_starship-theme` - Tab completion for theme names

## Key Features

### Theme Management
- **Multiple Themes**: 6 pre-configured themes for different preferences
- **Dynamic Switching**: Change themes instantly with `starship-theme set <name>`
- **Preview Mode**: Test themes without permanent changes
- **Tab Completion**: Smart completion for theme names and commands

### Theme Varieties

#### Minimal (`minimal.toml`)
- Directory path (truncated)
- Git branch (if in repo)
- Simple character prompt
- Fast and clean

#### Super Minimal (`super-minimal.toml`)
- Absolute minimum information
- Ultra-fast rendering
- Essential context only

#### Rainbow (`rainbow.toml`)
- Full information display
- Colorful indicators
- Git status, language versions
- System information

#### Catppuccin (`catppuccin.toml`)
- Matches Neovim colorscheme
- Consistent visual theme
- Aesthetic color palette

### Git Integration
- **Branch Display**: Current branch name with styling
- **Status Indicators**: Modified, staged, untracked files
- **Ahead/Behind**: Commits ahead/behind remote
- **Repository Context**: Automatic repo detection

### Performance Features
- **Lazy Loading**: Information computed only when needed
- **Caching**: Repeated information cached for speed
- **Async Rendering**: Non-blocking prompt updates
- **Minimal Dependencies**: Optimized for startup time

### Customization Options
- **Format Strings**: Flexible prompt layout configuration
- **Color Schemes**: Customizable colors for all elements
- **Module Control**: Enable/disable specific information modules
- **Truncation**: Smart path and text truncation

## Starship-Theme Tool

### Commands
- `starship-theme list` - Show available themes
- `starship-theme current` - Display current theme
- `starship-theme set <theme>` - Switch to specified theme
- `starship-theme preview <theme>` - Test theme temporarily
- `starship-theme help` - Show usage information

### Features
- **Smart Discovery**: Automatically finds theme files
- **Error Handling**: Graceful fallback for missing themes
- **Status Feedback**: Clear success/error messages
- **Tab Completion**: Context-aware completions

## Integration Points
- **Shell Integration**: Automatically loaded in Zsh configuration
- **Neovim Theme**: Catppuccin theme matches editor colorscheme
- **Git Workflow**: Enhanced git status display in prompt
- **Development**: Context-aware information for coding projects

## Configuration Structure

### Theme Files (TOML)
```toml
format = "$directory$git_branch$character"
add_newline = false

[directory]
style = "blue"
truncation_length = 2

[git_branch]
symbol = ""
style = "green"
```

### Module Categories
1. **Core**: directory, character, username, hostname
2. **Git**: branch, status, commit, stash
3. **Language**: python, node, rust, go, java versions
4. **System**: time, battery, memory, disk usage
5. **Cloud**: AWS, GCP, Azure context

## Performance Monitoring
Theme switching and prompt performance can be monitored via:
- Shell startup profiling (`make health-profile`)
- Starship timing information
- Theme-specific performance metrics