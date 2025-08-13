# Git Integration and Workflow

## Overview
Comprehensive Git configuration with enhanced diff viewing, extensive aliases, custom tools, and workflow optimizations. Integrates Delta for beautiful diffs and provides streamlined Git operations through shell aliases.

## How It Works
- **Enhanced Diff Display**: Delta for syntax-highlighted, side-by-side diffs
- **Comprehensive Aliases**: Full set of Git shortcuts for common operations
- **Custom Tools**: Additional Git utilities for specialized workflows
- **Editor Integration**: Neovim as default Git editor with syntax highlighting
- **Workflow Optimization**: Shortcuts for common development patterns

## Key Files

### Git Configuration
- `git/.gitconfig` - Main Git configuration with Delta, aliases, and settings
- `git/.gitignore` - Global gitignore patterns for development
- `.config/zsh/aliases.zsh` - Git aliases in shell (lines 88-143)

### Custom Git Tools
- `bin/git-show` - Enhanced git show with hash/offset support

### Integration Files
- Neovim Git plugins (`plugins/git.lua`)
- Starship Git prompt configuration
- Shell Git completion and functions

## Key Features

### Delta Diff Enhancement
- **Syntax Highlighting**: Language-aware diff coloring
- **Line Numbers**: Clear line number display
- **Navigation**: Easy navigation through large diffs
- **diff-so-fancy Style**: Familiar, clean diff presentation
- **Side-by-side Option**: Alternative viewing mode
- **Custom Themes**: Monokai Extended syntax theme

### Comprehensive Git Aliases

#### Basic Operations
- `g` → `git` - Quick git access
- `ga` → `git add` - Stage files
- `gaa` → `git add --all` - Stage all changes
- `gc` → `git commit` - Create commit
- `gcm`/`gcmsg` → `git commit --message` - Commit with message
- `gca` → `git commit --amend` - Amend last commit

#### Navigation and Information
- `gst` → `git status` - Repository status
- `gss` → `git status --short` - Compact status
- `gd` → `git diff` - View changes
- `gds` → `git diff --staged` - View staged changes
- `glog` → `git log --oneline --decorate --graph` - Pretty log

#### Branch Management
- `gb` → `git branch` - List branches
- `gba` → `git branch --all` - List all branches (including remote)
- `gcb` → `git checkout -b` - Create and switch to new branch
- `gco` → `git checkout` - Switch branches
- `gbd`/`gbD` → `git branch --delete` - Delete branches

#### Remote Operations
- `gl` → `git pull` - Pull changes
- `gp` → `git push` - Push changes
- `ggpush` → `git push origin $(current branch)` - Push current branch
- `ggpull` → `git pull origin $(current branch)` - Pull current branch
- `gf`/`gfa` → `git fetch` - Fetch changes

#### Advanced Operations
- `gsta` → `git stash push` - Stash changes
- `gstp` → `git stash pop` - Apply stash
- `grh`/`grhh` → `git reset` - Reset changes
- `grs` → `git restore --staged` - Unstage files
- `gapa` → `git add --patch` - Interactive staging

### Custom Git Tools

#### git-show Enhanced (`bin/git-show`)
- **Multiple Input Types**: Accepts hash, relative commit number, or defaults to HEAD
- **Flexible Usage**: `gs` (latest), `gs 1` (HEAD~1), `gs <hash>` (specific commit)
- **Smart Detection**: Automatically detects hash vs offset based on input length

### Workflow Optimizations

#### Branch Management
- `gcom` - Smart checkout to master or main branch
- `gap` - Interactive patch adding for selective staging
- Branch-aware push/pull with current branch detection

#### Development Workflow
- Quick status checking with short format
- Enhanced logging with graph visualization
- Patch-based adding for clean commits
- Stash management for context switching

### Git Configuration Features

#### Core Settings
- **Editor**: Neovim as default Git editor
- **Pager**: Delta for all Git output
- **Excludes**: Global gitignore file
- **Interactive**: Delta for interactive commands

#### Delta Configuration
- **Syntax Theme**: Monokai Extended for code highlighting
- **Line Numbers**: Always show line numbers
- **Navigation**: Enable diff navigation
- **Color Scheme**: Green/red for add/remove with emphasis
- **Header Styling**: Purple underlined headers

### Neovim Git Integration
- **Gitsigns**: Real-time Git status in editor gutter
- **Fugitive**: Comprehensive Git commands within Neovim
- **Conflict Resolution**: Enhanced merge conflict handling
- **Blame Integration**: Line-by-line Git blame information

### Starship Prompt Integration
- **Branch Display**: Current branch in prompt
- **Status Indicators**: Modified, staged, untracked file counts
- **Ahead/Behind**: Commit status relative to remote
- **Repository Detection**: Automatic Git repo recognition

## Integration Points
- **Shell Environment**: Git aliases integrated into Zsh configuration
- **Editor Workflow**: Neovim configured as Git editor with plugins
- **Prompt Display**: Git status in Starship prompt
- **Development Tools**: Git integrated into development workflow

## Advanced Features
- **Global Gitignore**: Comprehensive ignore patterns for development
- **Interactive Staging**: Patch-based file staging for clean commits
- **Enhanced History**: Beautiful, navigable Git history display
- **Smart Defaults**: Optimized Git settings for development workflow

## Performance Optimizations
- **Efficient Aliases**: Short, memorable aliases for frequent operations
- **Smart Caching**: Git status caching in prompt for performance
- **Lazy Loading**: Git-heavy operations loaded only when needed
- **Optimized Config**: Git configuration tuned for performance