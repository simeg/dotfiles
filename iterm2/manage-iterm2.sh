#!/usr/bin/env bash

# iTerm2 Settings Management Script
# Manages export/import of iTerm2 preferences

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ITERM_PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
DOTFILES_PLIST="$SCRIPT_DIR/com.googlecode.iterm2.plist"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_iterm_running() {
    if pgrep -f "iTerm" > /dev/null; then
        log_warning "iTerm2 is currently running"
        echo "For settings changes to take effect, you may need to:"
        echo "1. Quit iTerm2 completely"
        echo "2. Re-import settings"
        echo "3. Restart iTerm2"
        echo
        read -p "Continue anyway? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

export_settings() {
    log_info "Exporting current iTerm2 settings to dotfiles..."
    
    if [[ ! -f "$ITERM_PLIST" ]]; then
        log_error "iTerm2 preferences file not found at $ITERM_PLIST"
        exit 1
    fi
    
    cp "$ITERM_PLIST" "$DOTFILES_PLIST"
    log_success "Settings exported to $DOTFILES_PLIST"
}

import_settings() {
    log_info "Importing iTerm2 settings from dotfiles..."
    
    if [[ ! -f "$DOTFILES_PLIST" ]]; then
        log_error "Dotfiles preferences file not found at $DOTFILES_PLIST"
        log_info "Run 'export' first to create the initial settings file"
        exit 1
    fi
    
    check_iterm_running
    
    # Backup current settings
    if [[ -f "$ITERM_PLIST" ]]; then
        backup_file="${ITERM_PLIST}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$ITERM_PLIST" "$backup_file"
        log_info "Current settings backed up to $backup_file"
    fi
    
    cp "$DOTFILES_PLIST" "$ITERM_PLIST"
    
    # Reload preferences (this forces macOS to reload the plist)
    defaults read com.googlecode.iterm2 > /dev/null 2>&1 || true
    
    log_success "Settings imported from dotfiles"
    log_warning "Restart iTerm2 for all changes to take effect"
}

sync_settings() {
    log_info "Syncing current iTerm2 settings to dotfiles..."
    export_settings
}

show_usage() {
    echo "iTerm2 Settings Management"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  export    Export current iTerm2 settings to dotfiles"
    echo "  import    Import iTerm2 settings from dotfiles"
    echo "  sync      Sync current settings to dotfiles (alias for export)"
    echo "  status    Show current settings status"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 export    # Save current iTerm2 settings"
    echo "  $0 import    # Restore iTerm2 settings from dotfiles"
    echo ""
}

show_status() {
    echo "iTerm2 Settings Status"
    echo "======================"
    echo ""
    
    if [[ -f "$ITERM_PLIST" ]]; then
        echo "✅ Current iTerm2 settings: $(ls -lh "$ITERM_PLIST" | awk '{print $5, $6, $7, $8}')"
    else
        echo "❌ No current iTerm2 settings found"
    fi
    
    if [[ -f "$DOTFILES_PLIST" ]]; then
        echo "✅ Dotfiles iTerm2 settings: $(ls -lh "$DOTFILES_PLIST" | awk '{print $5, $6, $7, $8}')"
    else
        echo "❌ No dotfiles iTerm2 settings found (run 'export' first)"
    fi
    
    echo ""
    if pgrep -f "iTerm" > /dev/null; then
        echo "🟡 iTerm2 is currently running"
    else
        echo "✅ iTerm2 is not running"
    fi
}

# Main command handling
case "${1:-help}" in
    export)
        export_settings
        ;;
    import)
        import_settings
        ;;
    sync)
        sync_settings
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        log_error "Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac