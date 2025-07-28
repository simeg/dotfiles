#!/usr/bin/env bash

# Dotfiles modular configuration migration script
# Migrates existing config files to the modular ~/.config/zsh/ structure

set -e

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

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

migrate_modular_configs() {
    log_info "Migrating to modular configuration structure..."
    
    # Create the modular config directory
    mkdir -p "$HOME/.config/zsh"
    
    # List of config files to migrate
    local configs=(
        "aliases.zsh"
        "exports.zsh" 
        "functions.zsh"
        "misc.zsh"
        "path.zsh"
    )
    
    # Backup existing configs if they exist
    local backup_dir
    backup_dir="$HOME/.config/zsh/backup-$(date +%Y%m%d_%H%M%S)"
    local needs_backup=false
    
    for config in "${configs[@]}"; do
        if [[ -f "$HOME/.config/zsh/$config" ]]; then
            if [[ "$needs_backup" == false ]]; then
                log_info "Creating backup of existing modular configs..."
                mkdir -p "$backup_dir"
                needs_backup=true
            fi
            mv "$HOME/.config/zsh/$config" "$backup_dir/"
            log_warning "Backed up existing $config to $backup_dir/"
        fi
    done
    
    # Copy configs from dotfiles repo to modular location
    for config in "${configs[@]}"; do
        local source_file="$DOTFILES_ROOT/zsh/$config"
        local dest_file="$HOME/.config/zsh/$config"
        
        if [[ -f "$source_file" ]]; then
            cp "$source_file" "$dest_file"
            log_success "Migrated $config to modular structure"
        else
            log_warning "Config file $source_file not found, skipping..."
        fi
    done
    
    # Update aliases to point to new modular structure
    if [[ -f "$HOME/.config/zsh/aliases.zsh" ]]; then
        # Update the alias for editing aliases
        sed -i.bak 's|alias ali="vim ~/repos/dotfiles/shell/.alias"|alias ali="vim ~/.config/zsh/aliases.zsh"|g' "$HOME/.config/zsh/aliases.zsh"
        rm -f "$HOME/.config/zsh/aliases.zsh.bak"
        log_success "Updated aliases to point to modular config"
    fi
    
    log_success "Modular configuration migration completed!"
    log_info "Files are now located in: $HOME/.config/zsh/"
    log_info "Your .zshrc will automatically source these files"
}

create_gitignore_for_private() {
    log_info "Setting up .gitignore for private configs..."
    
    local gitignore_file="$HOME/.config/zsh/.gitignore"
    cat > "$gitignore_file" << 'EOF'
# Private configuration files - never commit these!
private.zsh
*.local.zsh
.env
.env.*
**/secrets.*
**/*.key
**/*.pem

# Backup files
backup-**/
*.bak
*.backup

# OS files
.DS_Store
Thumbs.db
EOF
    
    log_success "Created .gitignore for private configs at $gitignore_file"
}

main() {
    log_info "Starting modular configuration migration..."
    
    migrate_modular_configs
    create_gitignore_for_private
    
    log_success "Migration completed! Restart your shell or run 'source ~/.zshrc' to use the new configuration."
    log_info "Remember to create ~/.config/zsh/private.zsh for sensitive environment variables"
}

# Run migration if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi