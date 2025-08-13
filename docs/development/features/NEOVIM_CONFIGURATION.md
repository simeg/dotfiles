# Neovim Configuration

## Overview
Modern Neovim configuration with Lua-based setup, using lazy.nvim for plugin management. Provides a comprehensive development environment with LSP, completion, file navigation, and git integration.

## How It Works
- **Lua Configuration**: Modern approach using Lua instead of Vimscript
- **Lazy Loading**: Plugins loaded on-demand for optimal performance
- **Modular Structure**: Core settings and plugin configs separated
- **LSP Integration**: Language Server Protocol for intelligent code editing

## Key Files

### Core Configuration
- `.config/nvim/init.lua` - Main entry point
- `.config/nvim/lua/core/options.lua` - Basic Vim options and settings
- `.config/nvim/lua/core/keymaps.lua` - Custom key mappings
- `.config/nvim/lua/core/autocmds.lua` - Auto commands and events

### Plugin Management
- `.config/nvim/lua/plugins/lazy.lua` - Plugin definitions and lazy.nvim setup
- `.config/nvim/lua/plugins/lsp.lua` - Language Server Protocol configuration
- `.config/nvim/lua/plugins/completion.lua` - Code completion setup
- `.config/nvim/lua/plugins/treesitter.lua` - Syntax highlighting and parsing

### UI and Navigation
- `.config/nvim/lua/plugins/telescope.lua` - Fuzzy finder configuration
- `.config/nvim/lua/plugins/nvim-tree.lua` - File explorer setup
- `.config/nvim/lua/plugins/lualine.lua` - Status line configuration
- `.config/nvim/lua/plugins/colorscheme.lua` - Theme configuration

### Development Tools
- `.config/nvim/lua/plugins/git.lua` - Git integration (gitsigns, fugitive)
- `.config/nvim/lua/plugins/editing.lua` - Text editing enhancements

## Key Features

### Plugin Management (Lazy.nvim)
- **Automatic Installation**: Plugins installed on first run
- **Lazy Loading**: Plugins loaded only when needed
- **Performance**: Optimized startup time
- **Configuration**: Inline plugin configuration

### Language Support
- **LSP Integration**: Native Language Server Protocol support
- **Treesitter**: Advanced syntax highlighting and code understanding
- **Completion**: Intelligent code completion with nvim-cmp
- **Diagnostics**: Real-time error and warning display

### Navigation and Search
- **Telescope**: Fuzzy finder for files, buffers, git files, live grep
- **Nvim-tree**: File explorer with git status integration
- **Buffer Navigation**: Smart buffer switching and management

### Git Integration
- **Gitsigns**: Git diff indicators in gutter
- **Fugitive**: Comprehensive git commands within Neovim
- **Git Status**: Visual indicators for file changes

### UI Enhancements
- **Lualine**: Modern status line with git branch, LSP status
- **Catppuccin Theme**: Modern colorscheme with multiple flavors
- **Transparent Background**: Optional transparency support
- **Icons**: File type icons and visual enhancements

### Performance Optimizations
- **Big File Handling**: Special handling for large files (1MB+)
- **Lazy Loading**: Deferred plugin loading
- **Startup Time**: Optimized initialization sequence

## Configuration Structure

### Core Settings
- **Options**: Tab size, line numbers, search settings, clipboard
- **Keymaps**: Leader key mappings, window navigation, custom shortcuts
- **Autocmds**: File type detection, automatic formatting, buffer events

### Plugin Categories
1. **Core**: lazy.nvim, plenary (utilities)
2. **UI**: colorscheme, lualine, nvim-tree, telescope
3. **Editing**: treesitter, LSP, completion, snippets
4. **Git**: gitsigns, fugitive
5. **Utilities**: various text editing enhancements

## Integration Points
- **Shell Integration**: Accessed via `nvim`, `vim`, `vi`, `v` aliases
- **Git Workflow**: Integrated with git aliases and functions
- **Development**: Supports multiple languages with LSP servers
- **Terminal**: Can be used from integrated terminal sessions