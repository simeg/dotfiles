#!/usr/bin/env bash

# Package synchronization script
# Helps sync currently installed packages with dotfiles configuration

# Source shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=scripts/lib/brew-utils.sh
source "$SCRIPT_DIR/lib/brew-utils.sh"
# shellcheck source=scripts/lib/validation-utils.sh
source "$SCRIPT_DIR/lib/validation-utils.sh"
# shellcheck source=scripts/lib/error-handling.sh
source "$SCRIPT_DIR/lib/error-handling.sh"

# Initialize error handling
setup_error_handling "sync-packages.sh" false

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BREWFILE="$DOTFILES_DIR/install/Brewfile"
# Note: ENHANCED_BREWFILE may be used in future enhancements
# ENHANCED_BREWFILE="$DOTFILES_DIR/install/Brewfile.enhanced"

# Analyze current vs dotfiles packages
analyze_packages() {
    log_info "Analyzing installed packages vs dotfiles configuration..."

    # Get currently installed packages
    local current_formulae
    current_formulae=$(mktemp)
    brew list --formula | sort > "$current_formulae"

    local current_casks
    current_casks=$(mktemp)
    brew list --cask | sort > "$current_casks"

    # Get packages from current Brewfile
    local brewfile_formulae
    brewfile_formulae=$(mktemp)
    grep '^brew "' "$BREWFILE" | sed 's/^brew "//' | sed 's/".*//' | sort > "$brewfile_formulae"

    local brewfile_casks
    brewfile_casks=$(mktemp)
    grep '^cask "' "$BREWFILE" | sed 's/^cask "//' | sed 's/".*//' | sort > "$brewfile_casks"

    echo
    log_info "=== PACKAGE ANALYSIS ==="
    echo

    # Missing from Brewfile (installed but not in dotfiles)
    log_warning "Formulae installed but NOT in Brewfile:"
    local missing_formulae
    missing_formulae=$(comm -23 "$current_formulae" "$brewfile_formulae")
    if [[ -n "$missing_formulae" ]]; then
        printf '%s\n' "$missing_formulae" | while IFS= read -r formula; do echo "  - $formula"; done
        echo
        log_info "To add these to Brewfile:"
        echo "$missing_formulae" | sed 's/^/brew "/' | sed 's/$/"/' | sed 's/^/  /'
    else
        echo "  None"
    fi
    echo

    log_warning "Casks installed but NOT in Brewfile:"
    local missing_casks
    missing_casks=$(comm -23 "$current_casks" "$brewfile_casks")
    if [[ -n "$missing_casks" ]]; then
        printf '%s\n' "$missing_casks" | while IFS= read -r cask; do echo "  - $cask"; done
        echo
        log_info "To add these to Brewfile:"
        echo "$missing_casks" | sed 's/^/cask "/' | sed 's/$/"/' | sed 's/^/  /'
    else
        echo "  None"
    fi
    echo

    # In Brewfile but not installed
    log_warning "Formulae in Brewfile but NOT installed:"
    local uninstalled_formulae
    uninstalled_formulae=$(comm -13 "$current_formulae" "$brewfile_formulae")
    if [[ -n "$uninstalled_formulae" ]]; then
        printf '%s\n' "$uninstalled_formulae" | while IFS= read -r formula; do echo "  - $formula"; done
    else
        echo "  None"
    fi
    echo

    log_warning "Casks in Brewfile but NOT installed:"
    local uninstalled_casks
    uninstalled_casks=$(comm -13 "$current_casks" "$brewfile_casks")
    if [[ -n "$uninstalled_casks" ]]; then
        printf '%s\n' "$uninstalled_casks" | while IFS= read -r cask; do echo "  - $cask"; done
    else
        echo "  None"
    fi
    echo

    # Statistics
    local total_formulae_installed
    total_formulae_installed=$(wc -l < "$current_formulae")
    local total_casks_installed
    total_casks_installed=$(wc -l < "$current_casks")
    local total_formulae_brewfile
    total_formulae_brewfile=$(wc -l < "$brewfile_formulae")
    local total_casks_brewfile
    total_casks_brewfile=$(wc -l < "$brewfile_casks")

    log_info "=== STATISTICS ==="
    echo "  Formulae: $total_formulae_installed installed, $total_formulae_brewfile in Brewfile"
    echo "  Casks: $total_casks_installed installed, $total_casks_brewfile in Brewfile"

    # Cleanup
    rm -f "$current_formulae" "$current_casks" "$brewfile_formulae" "$brewfile_casks"
}

# Generate comprehensive Brewfile from current installation
generate_comprehensive_brewfile() {
    log_info "Generating comprehensive Brewfile from current installation..."

    local output_file="$DOTFILES_DIR/install/Brewfile.generated"

    cat > "$output_file" << EOF
# Generated Brewfile from current system
# Generated on: $(date)
# Total formulae: $(brew list --formula | wc -l)
# Total casks: $(brew list --cask | wc -l)

# ============================================================================
# FORMULAE
# ============================================================================

EOF

    # Add all formulae with comments
    brew list --formula | sort | while read -r formula; do
        local desc
        desc=$(brew desc "$formula" 2>/dev/null | head -1 || echo "")
        if [[ -n "$desc" ]]; then
            echo "# $desc" >> "$output_file"
        fi
        echo "brew \"$formula\"" >> "$output_file"
        echo >> "$output_file"
    done

    cat >> "$output_file" << EOF

# ============================================================================
# CASKS
# ============================================================================

EOF

    # Add all casks with comments
    brew list --cask | sort | while read -r cask; do
        local desc
        desc=$(brew desc --cask "$cask" 2>/dev/null | head -1 || echo "")
        if [[ -n "$desc" ]]; then
            echo "# $desc" >> "$output_file"
        fi
        echo "cask \"$cask\"" >> "$output_file"
        echo >> "$output_file"
    done

    # Add Mac App Store apps
    if command -v mas &> /dev/null; then
        cat >> "$output_file" << EOF

# ============================================================================
# MAC APP STORE APPS
# ============================================================================

EOF
        mas list | sort | while IFS= read -r line; do
            local id name
            id=$(echo "$line" | awk '{print $1}')
            name=$(echo "$line" | cut -d' ' -f2- | sed 's/ (.*//')
            echo "mas \"$name\", id: $id" >> "$output_file"
        done
    fi

    log_success "Generated comprehensive Brewfile: $output_file"
    log_info "Review this file and copy desired entries to your main Brewfile"
}

# Update current Brewfile with missing packages
update_brewfile() {
    log_info "Updating Brewfile with missing packages..."

    # Backup current Brewfile
    local backup_file
    backup_file="$BREWFILE.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$BREWFILE" "$backup_file"
    log_info "Backed up current Brewfile to: $backup_file"

    # Get missing packages
    local current_formulae
    current_formulae=$(mktemp)
    brew list --formula | sort > "$current_formulae"

    local current_casks
    current_casks=$(mktemp)
    brew list --cask | sort > "$current_casks"

    local brewfile_formulae
    brewfile_formulae=$(mktemp)
    grep '^brew "' "$BREWFILE" | sed 's/^brew "//' | sed 's/".*//' | sort > "$brewfile_formulae"

    local brewfile_casks
    brewfile_casks=$(mktemp)
    grep '^cask "' "$BREWFILE" | sed 's/^cask "//' | sed 's/".*//' | sort > "$brewfile_casks"

    # Add missing formulae
    local missing_formulae
    missing_formulae=$(comm -23 "$current_formulae" "$brewfile_formulae")
    if [[ -n "$missing_formulae" ]]; then
        echo >> "$BREWFILE"
        echo "# Added by sync-packages.sh on $(date)" >> "$BREWFILE"
        echo "$missing_formulae" | while read -r formula; do
            local desc
            desc=$(brew desc "$formula" 2>/dev/null | head -1 || echo "")
            if [[ -n "$desc" ]]; then
                echo "# $desc" >> "$BREWFILE"
            fi
            echo "brew \"$formula\"" >> "$BREWFILE"
        done
    fi

    # Add missing casks
    local missing_casks
    missing_casks=$(comm -23 "$current_casks" "$brewfile_casks")
    if [[ -n "$missing_casks" ]]; then
        echo >> "$BREWFILE"
        echo "# Casks added by sync-packages.sh on $(date)" >> "$BREWFILE"
        echo "$missing_casks" | while read -r cask; do
            local desc
            desc=$(brew desc --cask "$cask" 2>/dev/null | head -1 || echo "")
            if [[ -n "$desc" ]]; then
                echo "# $desc" >> "$BREWFILE"
            fi
            echo "cask \"$cask\"" >> "$BREWFILE"
        done
    fi

    log_success "Updated Brewfile with missing packages"

    # Cleanup
    rm -f "$current_formulae" "$current_casks" "$brewfile_formulae" "$brewfile_casks"
}

# Export package lists for other package managers
export_other_packages() {
    log_info "Exporting other package manager configurations..."

    local output_dir="$DOTFILES_DIR/install/packages"
    mkdir -p "$output_dir"

    # NPM global packages
    if command -v npm &> /dev/null; then
        npm list -g --depth=0 --json 2>/dev/null | jq -r '.dependencies | keys[]' > "$output_dir/npm-global.txt" 2>/dev/null || echo "No global npm packages" > "$output_dir/npm-global.txt"
        log_success "Exported NPM global packages to: $output_dir/npm-global.txt"
    fi

    # Python packages (pipx)
    if command -v pipx &> /dev/null; then
        pipx list --short > "$output_dir/pipx-packages.txt" 2>/dev/null || echo "No pipx packages" > "$output_dir/pipx-packages.txt"
        log_success "Exported pipx packages to: $output_dir/pipx-packages.txt"
    fi

    # VS Code extensions (if available)
    if command -v code &> /dev/null; then
        code --list-extensions > "$output_dir/vscode-extensions.txt" 2>/dev/null || echo "No VS Code extensions" > "$output_dir/vscode-extensions.txt"
        log_success "Exported VS Code extensions to: $output_dir/vscode-extensions.txt"
    fi

    # Mac App Store apps
    if command -v mas &> /dev/null; then
        mas list > "$output_dir/mas-apps.txt"
        log_success "Exported Mac App Store apps to: $output_dir/mas-apps.txt"
    fi
}

# Show usage
show_usage() {
    echo "Package Synchronization Tool"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  analyze     Analyze differences between installed packages and Brewfile"
    echo "  generate    Generate comprehensive Brewfile from current installation"
    echo "  update      Update current Brewfile with missing packages"
    echo "  export      Export package lists for other package managers"
    echo "  all         Run all operations"
    echo ""
}

# Main function
main() {
    case "${1:-analyze}" in
        analyze)
            analyze_packages
            ;;
        generate)
            generate_comprehensive_brewfile
            ;;
        update)
            update_brewfile
            ;;
        export)
            export_other_packages
            ;;
        all)
            analyze_packages
            generate_comprehensive_brewfile
            export_other_packages
            ;;
        --help|help)
            show_usage
            ;;
        *)
            log_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
