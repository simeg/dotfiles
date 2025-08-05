#!/usr/bin/env bash

# Comprehensive health check system for dotfiles
# Monitors configuration health, performance, and suggests optimizations

# Note: Not using 'set -e' to allow all checks to complete even if some fail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Health counters
CHECKS_RUN=0
CHECKS_PASSED=0
CHECKS_WARNING=0
CHECKS_FAILED=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
    CHECKS_WARNING=$((CHECKS_WARNING + 1))
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
}

run_check() {
    local check_name="$1"
    local check_function="$2"

    CHECKS_RUN=$((CHECKS_RUN + 1))

    echo -e "\n${BLUE}Running:${NC} $check_name"

    if $check_function; then
        return 0
    else
        return 1
    fi
}

# Performance health checks
check_shell_startup_performance() {
    local startup_times=()
    local total_ms=0

    # Run multiple tests for accuracy
    for _ in {1..3}; do
        local start_time
        start_time=$(gdate +%s%3N 2>/dev/null || date +%s%3N)
        zsh -c 'exit' 2>/dev/null
        local end_time
        end_time=$(gdate +%s%3N 2>/dev/null || date +%s%3N)
        local duration=$((end_time - start_time))

        startup_times+=("${duration}ms")
        total_ms=$((total_ms + duration))
    done

    local avg_ms=$((total_ms / 3))

    if [[ $avg_ms -lt 500 ]]; then
        log_success "Shell startup performance excellent (${avg_ms}ms average)"
    elif [[ $avg_ms -lt 1000 ]]; then
        log_success "Shell startup performance good (${avg_ms}ms average)"
    elif [[ $avg_ms -lt 2000 ]]; then
        log_warning "Shell startup performance moderate (${avg_ms}ms average)"
    else
        log_error "Shell startup performance poor (${avg_ms}ms average)"
        echo "    Consider running: ./scripts/profile-shell.sh for optimization"
        return 1
    fi

    return 0
}

# Configuration health checks
check_config_integrity() {
    local config_dir="$HOME/.config/zsh"
    local configs=("aliases.zsh" "exports.zsh" "functions.zsh" "misc.zsh" "path.zsh")
    local all_good=true

    # Check if modular configs exist and are valid
    for config in "${configs[@]}"; do
        local config_file="$config_dir/$config"
        if [[ ! -f "$config_file" ]]; then
            log_error "Missing config: $config"
            all_good=false
        elif ! zsh -n "$config_file" 2>/dev/null; then
            log_error "Syntax error in: $config"
            all_good=false
        fi
    done

    # Check main .zshrc
    if ! zsh -n "$HOME/.zshrc" 2>/dev/null; then
        log_error "Syntax error in .zshrc"
        all_good=false
    fi

    # Check private config if it exists
    if [[ -f "$config_dir/private.zsh" ]]; then
        if ! zsh -n "$config_dir/private.zsh" 2>/dev/null; then
            log_error "Syntax error in private.zsh"
            all_good=false
        fi
    fi

    if [[ "$all_good" == true ]]; then
        log_success "All configuration files are valid"
        return 0
    else
        return 1
    fi
}

# Plugin health check
check_plugin_health() {
    # Check znap installation
    if [[ ! -d "$HOME/.zsh/znap" ]]; then
        log_error "znap plugin manager not found"
        echo "    Install with: git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git ~/.zsh/znap"
        return 1
    fi

    # Check plugins file
    if [[ ! -f "$HOME/.znap-plugins.zsh" ]]; then
        log_error "znap plugins file missing"
        return 1
    fi

    # Test plugins file syntax
    if ! zsh -n "$HOME/.znap-plugins.zsh" 2>/dev/null; then
        log_error "Syntax error in plugins file"
        return 1
    fi

    # Count plugins
    local plugin_count
    plugin_count=$(grep -c "znap source" "$HOME/.znap-plugins.zsh" 2>/dev/null || echo 0)

    if [[ $plugin_count -gt 0 ]]; then
        log_success "Plugin system healthy ($plugin_count plugins configured)"
    else
        log_warning "No plugins configured"
    fi

    return 0
}

# Security health check
check_security_health() {
    local all_good=true

    # Check for private config security
    local config_dir="$HOME/.config/zsh"
    local gitignore_file="$config_dir/.gitignore"

    if [[ -f "$gitignore_file" ]] && grep -q "private.zsh" "$gitignore_file"; then
        log_success "Private configs are properly excluded from git"
    else
        log_warning "No .gitignore for private configs"
        echo "    Create: echo 'private.zsh' >> ~/.config/zsh/.gitignore"
        all_good=false
    fi

    # Check for sensitive data in tracked files
    if git log --all -p -S "password\|secret\|token\|key" --grep="password\|secret\|token\|key" | grep -q "password\|secret\|token\|key"; then
        log_error "Potential sensitive data found in git history"
        echo "    Review git history and remove sensitive data"
        all_good=false
    else
        log_success "No obvious sensitive data in git history"
    fi

    # Check SSH key permissions
    if [[ -d "$HOME/.ssh" ]]; then
        local bad_perms=false
        while IFS= read -r -d '' file; do
            local perms
            perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%A" "$file" 2>/dev/null)
            # Private keys (without .pub extension) should be 600
            if [[ "$file" == *"id_"* ]] && [[ "$file" != *".pub"* ]] && [[ "$perms" != "600" ]]; then
                log_warning "SSH private key has wrong permissions: $file ($perms, should be 600)"
                bad_perms=true
            # Public keys (.pub files) should be 644
            elif [[ "$file" == *"id_"*".pub" ]] && [[ "$perms" != "644" ]]; then
                log_warning "SSH public key has wrong permissions: $file ($perms, should be 644)"
                bad_perms=true
            fi
        done < <(find "$HOME/.ssh" -name "id_*" -type f -print0 2>/dev/null)

        if [[ "$bad_perms" == false ]]; then
            log_success "SSH key permissions are secure"
        fi
    fi

    if [[ "$all_good" == true ]]; then
        return 0
    else
        return 1
    fi
}

# Maintenance health check
check_maintenance_health() {
    local all_good=true

    # Check for old backup files
    local old_backups
    old_backups=$(find "$HOME" -maxdepth 1 -name ".dotfiles*backup*" -mtime +30 2>/dev/null | wc -l)
    if [[ $old_backups -gt 0 ]]; then
        log_warning "$old_backups old backup directories found"
        echo "    Consider cleaning up old backups in $HOME"
        all_good=false
    else
        log_success "No old backup directories found"
    fi

    # Check for large log files
    local large_logs
    large_logs=$(find "$HOME/.zsh" -name "*.log" -size +10M 2>/dev/null | wc -l)
    if [[ $large_logs -gt 0 ]]; then
        log_warning "$large_logs large log files found"
        echo "    Consider cleaning up log files"
        all_good=false
    else
        log_success "No large log files found"
    fi

    # Check Homebrew health (if available)
    if command -v brew &> /dev/null; then
        local brew_output
        if brew_output=$(brew doctor 2>&1); then
            log_success "Homebrew is healthy"
        else
            # Check if it's just warnings vs actual errors
            if echo "$brew_output" | grep -q "Warning:"; then
                log_warning "Homebrew has warnings"
                echo "    Run: brew doctor (for details)"
                all_good=false
            else
                log_error "Homebrew has serious issues"
                echo "    Run: brew doctor (for details)"
                all_good=false
            fi
        fi
    else
        log_info "Homebrew not installed (skipping)"
    fi

    if [[ "$all_good" == true ]]; then
        return 0
    else
        return 1
    fi
}

# Dependency health check
check_dependency_health() {
    local missing_deps=()
    local essential_tools=("git" "zsh")

    for tool in "${essential_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_deps+=("$tool")
        fi
    done

    if [[ ${#missing_deps[@]} -eq 0 ]]; then
        log_success "All essential dependencies are available"
        return 0
    else
        log_error "Missing essential dependencies: ${missing_deps[*]}"
        echo "    Run: ./scripts/check-deps.sh --install-essentials"
        return 1
    fi
}

# Function to find where a PATH entry might be set from
find_path_source() {
    local target_path="$1"
    local possible_sources=()
    
    # Check common locations where PATH might be set
    local config_files=(
        "$HOME/.zshrc"
        "$HOME/.config/zsh/path.zsh"
        "$HOME/.config/zsh/exports.zsh"
        "$HOME/.config/zsh/private.zsh"
        "$HOME/.profile"
        "$HOME/.bash_profile"
        "$HOME/.bashrc"
        "/etc/paths"
        "/etc/paths.d/*"
    )
    
    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" ]] && grep -q "$target_path" "$config_file" 2>/dev/null; then
            possible_sources+=("$config_file")
        fi
    done
    
    # Check /etc/paths.d/ directory
    if [[ -d "/etc/paths.d" ]]; then
        while IFS= read -r -d '' file; do
            if grep -q "$target_path" "$file" 2>/dev/null; then
                possible_sources+=("$file")
            fi
        done < <(find "/etc/paths.d" -type f -print0 2>/dev/null)
    fi
    
    # Check if it might be set by a tool installation
    local tool_indicators=(
        "homebrew:brew --prefix"
        "pyenv:pyenv root"
        "rbenv:rbenv root"
        "nvm:NVM_DIR"
        "cargo:CARGO_HOME"
        "go:GOPATH"
        "google-cloud-sdk:gcloud info --format='value(installation.sdk_root)'"
    )
    
    for indicator in "${tool_indicators[@]}"; do
        local tool_name="${indicator%:*}"
        local check_cmd="${indicator#*:}"
        
        if command -v "${tool_name}" &>/dev/null || [[ -n "${!tool_name}" ]]; then
            local tool_path
            if [[ "$check_cmd" == *"gcloud"* ]]; then
                tool_path=$(eval "$check_cmd" 2>/dev/null || echo "")
            else
                tool_path=$(eval "echo \$${check_cmd}" 2>/dev/null || echo "")
            fi
            
            if [[ -n "$tool_path" ]] && [[ "$target_path" == *"$tool_path"* ]]; then
                possible_sources+=("$tool_name installation")
            fi
        fi
    done
    
    printf '%s\n' "${possible_sources[@]}"
}

# Path health check
check_path_health() {
    local all_good=true

    # Check for duplicate PATH entries
    local path_entries
    IFS=':' read -ra path_entries <<< "$PATH"
    local unique_count
    unique_count=$(printf '%s\n' "${path_entries[@]}" | sort -u | wc -l)
    local total_count=${#path_entries[@]}

    if [[ $total_count -ne $unique_count ]]; then
        log_warning "Duplicate entries found in PATH ($total_count total, $unique_count unique)"
        echo "    Consider cleaning up PATH in your configs"
        all_good=false
    else
        log_success "PATH is clean (no duplicates)"
    fi

    # Check for non-existent directories in PATH
    local bad_paths=()
    for path_dir in "${path_entries[@]}"; do
        if [[ -n "$path_dir" ]] && [[ ! -d "$path_dir" ]]; then
            bad_paths+=("$path_dir")
        fi
    done

    if [[ ${#bad_paths[@]} -gt 0 ]]; then
        log_warning "Found ${#bad_paths[@]} non-existent directories in PATH:"
        for bad_path in "${bad_paths[@]}"; do
            echo "    ❌ $bad_path"
            
            # Try to find where this PATH entry might be coming from
            local sources
            sources=$(find_path_source "$bad_path")
            if [[ -n "$sources" ]]; then
                echo "       Likely set by: $sources"
            else
                echo "       Source: unknown (check shell startup files)"
            fi
        done
        echo "    💡 To fix: Remove these entries from the identified files or create the missing directories"
        all_good=false
    else
        log_success "All PATH directories exist"
    fi

    if [[ "$all_good" == true ]]; then
        return 0
    else
        return 1
    fi
}

# Generate health report
generate_health_report() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local report_file
    report_file="$HOME/.config/zsh/health-report-$(date +%Y%m%d_%H%M%S).txt"

    cat > "$report_file" << EOF
Dotfiles Health Report
Generated: $timestamp

== SUMMARY ==
Total Checks: $CHECKS_RUN
Passed: $CHECKS_PASSED
Warnings: $CHECKS_WARNING
Failed: $CHECKS_FAILED

== RECOMMENDATIONS ==
EOF

    if [[ $CHECKS_FAILED -gt 0 ]]; then
        cat >> "$report_file" << EOF

CRITICAL ISSUES FOUND:
- Run './validate.sh' for detailed diagnostics
- Fix any configuration syntax errors
- Install missing dependencies with './scripts/check-deps.sh'
EOF
    fi

    if [[ $CHECKS_WARNING -gt 0 ]]; then
        cat >> "$report_file" << EOF

OPTIMIZATIONS SUGGESTED:
- Run './scripts/profile-shell.sh' for performance analysis
- Clean up old backup files and logs
- Review and optimize PATH configuration
EOF
    fi

    if [[ $CHECKS_FAILED -eq 0 ]] && [[ $CHECKS_WARNING -eq 0 ]]; then
        cat >> "$report_file" << EOF

EXCELLENT HEALTH:
- All systems are functioning optimally
- No immediate action required
- Continue regular maintenance
EOF
    fi

    echo "Health report saved to: $report_file"
}

# Run comprehensive health check
run_comprehensive_health_check() {
    echo "========================================="
    echo "      Dotfiles Health Check System"
    echo "========================================="

    run_check "Shell Performance" check_shell_startup_performance
    run_check "Configuration Integrity" check_config_integrity
    run_check "Plugin Health" check_plugin_health
    run_check "Security Health" check_security_health
    run_check "Maintenance Health" check_maintenance_health
    run_check "Dependency Health" check_dependency_health
    run_check "PATH Health" check_path_health

    echo
    echo "========================================="
    echo "             Health Summary"
    echo "========================================="
    echo -e "Total checks: $CHECKS_RUN"
    echo -e "${GREEN}Passed: $CHECKS_PASSED${NC}"
    echo -e "${YELLOW}Warnings: $CHECKS_WARNING${NC}"
    echo -e "${RED}Failed: $CHECKS_FAILED${NC}"
    echo "========================================="

    if [[ $CHECKS_FAILED -eq 0 ]] && [[ $CHECKS_WARNING -eq 0 ]]; then
        echo -e "\n${GREEN}🎉 Excellent health! Your dotfiles are in great shape.${NC}"
    elif [[ $CHECKS_FAILED -eq 0 ]]; then
        echo -e "\n${YELLOW}⚠️  Good health with some optimizations available.${NC}"
    else
        echo -e "\n${RED}❌ Issues found that need attention.${NC}"
    fi

    generate_health_report
}

# Show help
show_help() {
    echo "Dotfiles Health Check System"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help         Show this help message"
    echo "  --performance  Check only performance metrics"
    echo "  --security     Check only security aspects"
    echo "  --config       Check only configuration integrity"
    echo "  --maintenance  Check only maintenance items"
    echo "  --quick        Run essential checks only"
    echo ""
    echo "Examples:"
    echo "  $0                 # Full health check"
    echo "  $0 --quick         # Quick essential checks"
    echo "  $0 --performance   # Performance analysis only"
    echo ""
}

# Main function
main() {
    case "${1:-}" in
        --help)
            show_help
            exit 0
            ;;
        --performance)
            run_check "Shell Performance" check_shell_startup_performance
            ;;
        --security)
            run_check "Security Health" check_security_health
            ;;
        --config)
            run_check "Configuration Integrity" check_config_integrity
            ;;
        --maintenance)
            run_check "Maintenance Health" check_maintenance_health
            ;;
        --quick)
            run_check "Configuration Integrity" check_config_integrity
            run_check "Dependency Health" check_dependency_health
            run_check "Shell Performance" check_shell_startup_performance
            ;;
        "")
            run_comprehensive_health_check
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run health check
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
