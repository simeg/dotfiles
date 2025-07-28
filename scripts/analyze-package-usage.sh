#!/usr/bin/env bash

# Package Usage Analytics System
# Analyzes which installed packages are actually being used

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

# Configuration
ANALYTICS_DIR="$HOME/.config/dotfiles"
USAGE_LOG="$ANALYTICS_DIR/command-usage.log"
PACKAGE_MAPPING="$ANALYTICS_DIR/package-mapping.cache"

# Ensure analytics directory exists
mkdir -p "$ANALYTICS_DIR"

# Create package mapping (command -> package)
create_package_mapping() {
    log_info "Creating package mapping cache..."
    
    # Clear existing cache
    true > "$PACKAGE_MAPPING"
    
    # Map brew formulae to their commands
    while IFS= read -r formula; do
        if command -v "$formula" &> /dev/null; then
            echo "$formula:$formula" >> "$PACKAGE_MAPPING"
        fi
        
        # Check for common alternative command names
        case "$formula" in
            "ripgrep") echo "rg:ripgrep" >> "$PACKAGE_MAPPING" ;;
            "fd") echo "fd:fd" >> "$PACKAGE_MAPPING" ;;
            "bat") echo "bat:bat" >> "$PACKAGE_MAPPING" ;;
            "eza") echo "eza:eza" >> "$PACKAGE_MAPPING" ;;
            "glow") echo "glow:glow" >> "$PACKAGE_MAPPING" ;;
            "fzf") echo "fzf:fzf" >> "$PACKAGE_MAPPING" ;;
            "jq") echo "jq:jq" >> "$PACKAGE_MAPPING" ;;
            "tree") echo "tree:tree" >> "$PACKAGE_MAPPING" ;;
            "htop") echo "htop:htop" >> "$PACKAGE_MAPPING" ;;
            "btop") echo "btop:btop" >> "$PACKAGE_MAPPING" ;;
            "zoxide") echo "z:zoxide" >> "$PACKAGE_MAPPING" ;;
            "starship") echo "starship:starship" >> "$PACKAGE_MAPPING" ;;
            "kubectl") echo "kubectl:kubectl" >> "$PACKAGE_MAPPING" ;;
            "docker") echo "docker:docker" >> "$PACKAGE_MAPPING" ;;
            "git") echo "git:git" >> "$PACKAGE_MAPPING" ;;
            "vim") echo "vim:vim" >> "$PACKAGE_MAPPING" ;;
            "node") echo "node:node" >> "$PACKAGE_MAPPING" ;;
            "npm") echo "npm:node" >> "$PACKAGE_MAPPING" ;;
            "python3") echo "python3:python@3.12" >> "$PACKAGE_MAPPING" ;;
            "python") echo "python:python@3.12" >> "$PACKAGE_MAPPING" ;;
            "go") echo "go:go" >> "$PACKAGE_MAPPING" ;;
            "cargo") echo "cargo:rust" >> "$PACKAGE_MAPPING" ;;
            "rustc") echo "rustc:rust" >> "$PACKAGE_MAPPING" ;;
            "mvn") echo "mvn:maven" >> "$PACKAGE_MAPPING" ;;
            "scala") echo "scala:scala" >> "$PACKAGE_MAPPING" ;;
            "sbt") echo "sbt:sbt" >> "$PACKAGE_MAPPING" ;;
        esac
    done < <(brew list --formula)
    
    log_success "Package mapping cache created with $(wc -l < "$PACKAGE_MAPPING") entries"
}

# Get package for command
get_package_for_command() {
    local cmd="$1"
    local base_cmd
    base_cmd=$(echo "$cmd" | awk '{print $1}')
    
    if [[ -f "$PACKAGE_MAPPING" ]]; then
        grep "^$base_cmd:" "$PACKAGE_MAPPING" | cut -d: -f2 | head -1
    fi
}

# Analyze usage patterns
analyze_usage_patterns() {
    local days="${1:-30}"
    log_info "Analyzing package usage for last $days days..."
    
    if [[ ! -f "$USAGE_LOG" ]]; then
        log_warning "No usage data found. Usage tracking needs to be enabled."
        log_info "Add the tracking hooks to your .zshrc to start collecting data."
        return 1
    fi
    
    local cutoff_date
    cutoff_date=$(date -d "$days days ago" +%s 2>/dev/null || date -v-"$days"d +%s)
    
    # Create temporary files for analysis
    local recent_commands used_packages unused_packages package_frequency
    recent_commands=$(mktemp)
    used_packages=$(mktemp)
    unused_packages=$(mktemp)
    package_frequency=$(mktemp)
    
    # Extract recent commands
    awk -F',' -v cutoff="$cutoff_date" '$1 >= cutoff {print $2}' "$USAGE_LOG" > "$recent_commands"
    
    # Map commands to packages and count usage
    while IFS= read -r cmd; do
        local package
        package=$(get_package_for_command "$cmd")
        if [[ -n "$package" ]]; then
            echo "$package"
        fi
    done < "$recent_commands" | sort | uniq -c | sort -nr > "$package_frequency"
    
    # Get list of used packages
    awk '{print $2}' "$package_frequency" > "$used_packages"
    
    # Find unused packages
    comm -23 <(brew list --formula | sort) <(sort "$used_packages") > "$unused_packages"
    
    echo
    log_success "=== PACKAGE USAGE ANALYSIS ($days days) ==="
    echo
    
    # Show most used packages
    log_info "🏆 Most Frequently Used Packages:"
    head -10 "$package_frequency" | while read -r count package; do
        echo "  $count uses: $package"
    done
    echo
    
    # Show recently used packages
    local total_used
    total_used=$(wc -l < "$used_packages")
    log_info "✅ Recently Used Packages ($total_used total):"
    head -20 "$used_packages" | sed 's/^/  - /'
    if [[ $total_used -gt 20 ]]; then
        echo "  ... and $((total_used - 20)) more"
    fi
    echo
    
    # Show unused packages
    local total_unused
    total_unused=$(wc -l < "$unused_packages")
    if [[ $total_unused -gt 0 ]]; then
        log_warning "🗑️  Unused Packages ($total_unused total - consider removing):"
        head -20 "$unused_packages" | sed 's/^/  - /'
        if [[ $total_unused -gt 20 ]]; then
            echo "  ... and $((total_unused - 20)) more"
        fi
        echo
        
        log_info "💡 To remove unused packages:"
        echo "  brew uninstall $(head -10 "$unused_packages" | tr '\n' ' ')"
    else
        log_success "🎉 All packages have been used recently!"
    fi
    echo
    
    # Package size analysis
    log_info "📦 Package Size Analysis:"
    analyze_package_sizes "$unused_packages" "$used_packages"
    
    # Cleanup
    rm -f "$recent_commands" "$used_packages" "$unused_packages" "$package_frequency"
}

# Analyze package sizes to show potential space savings
analyze_package_sizes() {
    local unused_packages="$1"
    local used_packages="$2"
    
    local total_unused_size=0
    local package_count=0
    local total_packages
    total_packages=$(wc -l < "$unused_packages")
    
    # Skip size analysis if there are too many packages (would be too slow)
    if [[ $total_packages -gt 50 ]]; then
        echo "  💾 Estimated space savings: ~$((total_packages * 50))MB (${total_packages} unused packages × 50MB average)"
        return
    fi
    
    echo -n "  📊 Analyzing package sizes"
    
    while IFS= read -r package; do
        if [[ -n "$package" ]]; then
            ((package_count++))
            
            # Show progress indicator
            if (( package_count % 5 == 0 )); then
                echo -n "."
            fi
            
            local size
            size=$(brew info --json "$package" 2>/dev/null | jq -r '.[0].installed[0].installed_on_request // empty' 2>/dev/null || echo "")
            if [[ -n "$size" ]]; then
                total_unused_size=$((total_unused_size + 100)) # Estimate 100MB per package
            fi
        fi
    done < "$unused_packages"
    
    echo # New line after progress dots
    
    if [[ $total_unused_size -gt 0 ]]; then
        echo "  💾 Estimated space savings from removing unused packages: ~${total_unused_size}MB"
    fi
}

# Generate usage report
generate_usage_report() {
    local output_file="${1:-$HOME/package-usage-report.txt}"
    log_info "Generating comprehensive usage report..."
    
    {
        echo "Package Usage Report"
        echo "Generated: $(date)"
        echo "================================="
        echo
        
        echo "SUMMARY:"
        echo "- Total brew packages: $(brew list --formula | wc -l)"
        echo "- Usage data points: $(wc -l < "$USAGE_LOG" 2>/dev/null || echo "0")"
        echo "- Data collection period: $(get_data_collection_period)"
        echo
        
        # Run analysis and capture output
        analyze_usage_patterns 30
        echo
        analyze_usage_patterns 7
        
    } > "$output_file"
    
    log_success "Report saved to: $output_file"
}

# Get data collection period
get_data_collection_period() {
    if [[ -f "$USAGE_LOG" ]]; then
        local first_entry last_entry
        first_entry=$(head -1 "$USAGE_LOG" | cut -d',' -f1)
        last_entry=$(tail -1 "$USAGE_LOG" | cut -d',' -f1)
        
        if [[ -n "$first_entry" && -n "$last_entry" ]]; then
            local days_diff
            days_diff=$(( (last_entry - first_entry) / 86400 ))
            echo "$days_diff days"
        else
            echo "No data"
        fi
    else
        echo "No data collected"
    fi
}

# Clean old usage data
clean_old_data() {
    local keep_days="${1:-90}"
    log_info "Cleaning usage data older than $keep_days days..."
    
    if [[ -f "$USAGE_LOG" ]]; then
        local cutoff_date temp_file
        cutoff_date=$(date -d "$keep_days days ago" +%s 2>/dev/null || date -v-"$keep_days"d +%s)
        temp_file=$(mktemp)
        
        awk -F',' -v cutoff="$cutoff_date" '$1 >= cutoff' "$USAGE_LOG" > "$temp_file"
        mv "$temp_file" "$USAGE_LOG"
        
        log_success "Cleaned old usage data"
    fi
}

# Show help
show_help() {
    echo "Package Usage Analytics"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  analyze [days]    Analyze package usage (default: 30 days)"
    echo "  report [file]     Generate comprehensive usage report"
    echo "  clean [days]      Clean usage data older than X days (default: 90)"
    echo "  mapping           Recreate package-to-command mapping cache"
    echo "  setup             Set up usage tracking (add hooks to shell)"
    echo ""
    echo "Examples:"
    echo "  $0 analyze 7      # Analyze last 7 days"
    echo "  $0 report         # Generate full report"
    echo "  $0 clean 60       # Keep only last 60 days of data"
}

# Set up usage tracking
setup_tracking() {
    log_info "Setting up package usage tracking..."
    
    local zshrc_addition="
# Package Usage Analytics (added by analyze-package-usage.sh)
if [[ -f ~/.config/dotfiles/usage-analytics.sh ]]; then
    source ~/.config/dotfiles/usage-analytics.sh
fi"
    
    # Check if already added
    if grep -q "Package Usage Analytics" ~/.zshrc 2>/dev/null; then
        log_info "Usage tracking already set up in .zshrc"
    else
        echo "$zshrc_addition" >> ~/.zshrc
        log_success "Added usage tracking to .zshrc"
        log_info "Please restart your shell or run: source ~/.zshrc"
    fi
}

# Main function
main() {
    case "${1:-analyze}" in
        analyze)
            create_package_mapping
            analyze_usage_patterns "${2:-30}"
            ;;
        report)
            create_package_mapping
            generate_usage_report "$2"
            ;;
        clean)
            clean_old_data "${2:-90}"
            ;;
        mapping)
            create_package_mapping
            ;;
        setup)
            setup_tracking
            ;;
        --help|help)
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi