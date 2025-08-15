# Custom Utilities and Bin Tools

## Overview
Collection of custom command-line utilities and scripts that enhance daily development workflow. These tools are symlinked to PATH and provide specialized functionality for common tasks, file operations, and development workflows.

## How It Works
- **PATH Integration**: All tools in `bin/` directory are symlinked to ~/.bin and added to PATH
- **Shell Integration**: Tools accessible from anywhere in the shell
- **Language Variety**: Mix of Bash, Python, and other languages based on tool requirements
- **Workflow Focus**: Each tool solves specific development workflow problems

## Key Files and Tools

### File and Content Operations

#### smart-cat (`bin/smart-cat`)
- **Purpose**: Intelligent file viewer that chooses appropriate tool based on file type
- **Features**: Uses `glow` for markdown files, `bat` for other files
- **Usage**: `cat file.md` (aliased) → beautifully rendered markdown
- **Fallback**: Gracefully falls back to `bat` if `glow` unavailable

#### backup (`bin/backup`)
- **Purpose**: Quick backup creation for files/directories
- **Features**: Creates timestamped backups
- **Usage**: `backup file.txt` → creates `file.txt.backup.YYYYMMDD-HHMMSS`

### Git and Development Workflow

#### gforbm (`bin/gforbm`)
- **Purpose**: "Git Fetch Origin Rebase Main" - smart branch rebasing
- **Features**:
  - Auto-detects default branch (main/master)
  - Safely rebases current branch onto updated main
  - Handles detached HEAD states
  - Prunes stale remote branches
- **Workflow**: Keeps feature branches up-to-date with main

#### git-show (`bin/git-show`)
- **Purpose**: Enhanced git show with flexible commit specification
- **Features**: Accepts hash, relative numbers, or defaults to HEAD
- **Usage**: `gs` (HEAD), `gs 1` (HEAD~1), `gs a1b2c3d` (specific hash)

#### fixup (`bin/fixup`)
- **Purpose**: Quick git fixup commits
- **Features**: Creates fixup commits for previous commits
- **Usage**: `fixup` → interactive fixup commit creation

#### squash (`bin/squash`)
- **Purpose**: Simplified commit squashing
- **Features**: Interactive squashing of recent commits
- **Usage**: `squash 3` → squash last 3 commits

#### super-amend (`bin/super-amend`)
- **Purpose**: Enhanced git commit amending
- **Features**: Amend commits with additional options
- **Usage**: More flexible than standard `git commit --amend`

### System and Productivity Tools

#### cpwd (`bin/cpwd`)
- **Purpose**: Copy current working directory to clipboard
- **Features**: Quick path copying for sharing or documentation
- **Usage**: `cpwd` → current directory path copied to clipboard

#### rssh (`bin/rssh`)
- **Purpose**: Rapid SSH connection management
- **Features**: Quick SSH connections with saved configurations
- **Usage**: `rssh server-name` → connects to predefined server

#### perf-dashboard (`bin/perf-dashboard`)
- **Purpose**: Interactive performance monitoring dashboard
- **Features**: Real-time system and dotfiles performance metrics
- **Integration**: Part of analytics system
- **Usage**: `perf-dashboard` → launches interactive dashboard

#### starship-theme (`bin/starship-theme`)
- **Purpose**: Starship prompt theme manager
- **Features**: Switch between themes, preview, list available
- **Tab Completion**: Smart completion for theme names
- **Usage**: `starship-theme set minimal` → switches to minimal theme

### Specialized Utilities

#### spuri (`bin/spuri`)
- **Purpose**: Spotify URI converter and handler
- **Features**: Convert between Spotify URI formats
- **Language**: Python-based utility
- **Usage**: Handles various Spotify link and URI conversions

## Tool Categories

### File Operations
- **smart-cat**: Intelligent file viewing
- **backup**: File/directory backup creation
- **cpwd**: Directory path copying

### Git Workflow
- **gforbm**: Smart branch rebasing
- **git-show**: Enhanced commit viewing
- **fixup**: Fixup commit creation
- **squash**: Commit squashing
- **super-amend**: Enhanced commit amending

### System Productivity
- **rssh**: SSH connection management
- **perf-dashboard**: Performance monitoring
- **starship-theme**: Prompt theme management

### Specialized Tools
- **spuri**: Spotify URI handling

## Integration Features

### Shell Integration
- **Aliases**: Many tools aliased in shell configuration
- **PATH Access**: All tools available system-wide
- **Tab Completion**: Custom completions for relevant tools
- **Shell Functions**: Some tools wrapped in shell functions for enhanced functionality

### Workflow Integration
- **Git Workflow**: Git tools integrate with existing git aliases
- **Development**: Tools support common development patterns
- **Productivity**: System tools enhance daily workflow efficiency
- **Analytics**: Performance tools integrate with monitoring system

### Safety Features
- **Error Handling**: Robust error handling in all scripts
- **Validation**: Input validation and sanity checks
- **Fallbacks**: Graceful degradation when dependencies unavailable
- **User Feedback**: Clear success/error messages

## Tool Design Principles

### Consistency
- **Naming**: Clear, descriptive tool names
- **Interface**: Consistent command-line interfaces
- **Documentation**: Each tool includes usage information
- **Error Messages**: Clear, actionable error messages

### Performance
- **Fast Execution**: Tools optimized for quick execution
- **Minimal Dependencies**: Limited external dependencies
- **Efficient Implementation**: Language choice based on tool requirements
- **Caching**: Where appropriate, tools use caching for performance

### Reliability
- **Error Handling**: Comprehensive error handling
- **Edge Cases**: Handles common edge cases
- **Testing**: Tools tested as part of CI pipeline
- **Maintenance**: Regular updates and maintenance

## Development Guidelines
- **Single Purpose**: Each tool has a focused, single purpose
- **Composability**: Tools designed to work together
- **Documentation**: Clear usage and purpose documentation
- **Shell Integration**: Designed for shell environment usage

## Extension Points
- **New Tools**: Easy to add new utilities to bin/ directory
- **Language Flexibility**: Support for any language with shebang
- **Configuration**: Tools can use dotfiles configuration
- **Integration**: Tools can integrate with existing systems