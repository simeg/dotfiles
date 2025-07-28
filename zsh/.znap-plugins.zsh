#!/bin/zsh

# 🔤 Syntax & Highlighting (order matters for these)

# Adds real-time syntax highlighting as you type commands
znap source zsh-users/zsh-syntax-highlighting

# Lets you search your command history with multiple words (like fuzzy grep)
znap source zsh-users/zsh-history-substring-search

# Suggests completions from your history as you type (like fish shell)
znap source zsh-users/zsh-autosuggestions

# Adds many useful command completions from third-party tools
znap source ohmyzsh/ohmyzsh lib/directories        # Common directory-related aliases
znap source ohmyzsh/ohmyzsh plugins/common-aliases # Widely used, memorable aliases (like ll, l, la, etc.)

# To speed up shell start
znap source marlonrichert/zsh-autocomplete

# 💡 UX Enhancements

# Enables 256-color support in terminals that may not default to it
znap source chrissicool/zsh-256color

# Enhances history search with smarter multi-word matches and display
znap source zdharma-continuum/history-search-multi-word

# 💻 Oh-My-Zsh plugins

# Git plugin: adds aliases and functions like `gst`, `gl`, `gco`, etc.
znap source ohmyzsh/ohmyzsh                        # Load shared lib functions (required by many plugins)
znap source ohmyzsh/ohmyzsh plugins/git

# MacOS plugin: adds utilities for macOS like `tab`, `quick-look`, `man-preview`
znap source ohmyzsh/ohmyzsh plugins/macos

# Colorizes `man` pages for better readability
znap source ohmyzsh/ohmyzsh plugins/colored-man-pages

# Enable lazy loading
export NVM_LAZY_LOAD=true
znap source lukechilds/zsh-nvm
