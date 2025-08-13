#!/usr/bin/env bash

# Advanced Testing Framework
# Provides configuration validation, performance regression testing, and security compliance checks

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
WARNINGS=0

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ANALYTICS_DIR="$HOME/.config/dotfiles"
PERF_BASELINE="$ANALYTICS_DIR/perf-baseline.json"
SECURITY_BASELINE="$ANALYTICS_DIR/security-baseline.json"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_security() {
    echo -e "${PURPLE}[SECURITY]${NC} $1"
}

# Test framework functions
run_test() {
    local test_name="$1"
    local test_function="$2"
    local is_warning="${3:-false}"

    echo -e "\n${CYAN}Testing:${NC} $test_name"
    TESTS_RUN=$((TESTS_RUN + 1))

    if $test_function; then
        log_success "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        if [[ "$is_warning" == "true" ]]; then
            log_warning "$test_name (non-critical)"
            WARNINGS=$((WARNINGS + 1))
            TESTS_PASSED=$((TESTS_PASSED + 1))  # Count warnings as passes for CI
            return 0
        else
            log_error "$test_name"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi
    fi
}

# =============================================================================
# CONFIGURATION VALIDATION TESTS
# =============================================================================

# Validate Zsh configuration completeness
test_zsh_config_validation() {
    local zsh_config_dir="$DOTFILES_DIR/.config/zsh"
    local required_files=(".zshrc" "aliases.zsh" "exports.zsh" "functions.zsh" "misc.zsh" "path.zsh")
    local issues=0
    
    # Check all required files exist
    for file in "${required_files[@]}"; do
        if [[ ! -f "$zsh_config_dir/$file" ]]; then
            echo "Missing required Zsh config: $file"
            issues=$((issues + 1))
        fi
    done
    
    # Validate .zshrc sources all modules
    local zshrc="$zsh_config_dir/.zshrc"
    if [[ -f "$zshrc" ]]; then
        for module in "aliases" "exports" "functions" "misc" "path"; do
            if ! grep -q "$module.zsh" "$zshrc"; then
                echo ".zshrc doesn't source $module.zsh"
                issues=$((issues + 1))
            fi
        done
    fi
    
    # Check for dangerous command redefinitions (unsafe patterns)
    local dangerous_patterns=("alias rm=" "alias chmod=" "alias chown=" "alias sudo=")
    for pattern in "${dangerous_patterns[@]}"; do
        if grep -q "$pattern" "$zsh_config_dir/aliases.zsh" 2>/dev/null; then
            # Exclude safe patterns (with -i interactive flag or similar safety measures)
            if ! grep -E "$pattern.*(-i|--interactive)" "$zsh_config_dir/aliases.zsh" >/dev/null 2>&1; then
                local cmd
                cmd=$(echo "$pattern" | sed 's/alias //; s/=//')
                echo "Warning: Potentially dangerous alias redefinition: $cmd"
                issues=$((issues + 1))
            fi
        fi
    done
    
    return $issues
}

# Validate Neovim configuration structure
test_neovim_config_validation() {
    local nvim_config="$DOTFILES_DIR/.config/nvim"
    local issues=0
    
    if [[ ! -d "$nvim_config" ]]; then
        echo "Neovim config directory missing"
        return 1
    fi
    
    # Check for required structure
    local required_dirs=("lua/core" "lua/plugins")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$nvim_config/$dir" ]]; then
            echo "Missing Neovim config directory: $dir"
            issues=$((issues + 1))
        fi
    done
    
    # Check init.lua exists
    if [[ ! -f "$nvim_config/init.lua" ]]; then
        echo "Missing init.lua"
        issues=$((issues + 1))
    fi
    
    # Note: Lua syntax validation is skipped as Neovim configs require Neovim's Lua environment
    # We just check that the files exist and are readable
    local lua_files
    lua_files=$(find "$nvim_config" -name "*.lua" -type f | wc -l)
    if [[ $lua_files -eq 0 ]]; then
        echo "No Lua configuration files found"
        issues=$((issues + 1))
    fi
    
    return $issues
}

# Validate Git configuration security
test_git_config_validation() {
    local git_dir="$DOTFILES_DIR/git"
    local issues=0
    local local_gitconfig="$git_dir/.gitconfig"
    local use_global=false
    
    # Determine which Git config to check
    if [[ -f "$local_gitconfig" ]]; then
        echo "Checking local dotfiles Git config: $local_gitconfig"
    else
        echo "No local Git config found, checking global Git configuration"
        use_global=true
    fi
    
    # Check for required configurations
    local required_configs=("user.name" "user.email" "core.editor")
    for config in "${required_configs[@]}"; do
        local config_found=false
        
        if [[ "$use_global" == "true" ]]; then
            # Check global Git configuration
            if git config --global --get "$config" >/dev/null 2>&1; then
                config_found=true
            fi
        else
            # Check local dotfiles Git configuration using git config command
            if git config --file "$local_gitconfig" --get "$config" >/dev/null 2>&1; then
                config_found=true
            fi
        fi
        
        if [[ "$config_found" == "false" ]]; then
            echo "Missing Git configuration: $config"
            issues=$((issues + 1))
        fi
    done
    
    # Security: Check for hardcoded credentials (only in local config)
    if [[ "$use_global" == "false" ]] && grep -E "(password|token|secret)" "$local_gitconfig" >/dev/null 2>&1; then
        echo "Security warning: Potential credentials in Git config"
        issues=$((issues + 1))
    fi
    
    # Check .gitignore effectiveness
    local gitignore="$git_dir/.gitignore"
    if [[ -f "$gitignore" ]]; then
        local sensitive_patterns=(".env" "*.key" "*.pem" "config/secrets" "node_modules" ".DS_Store")
        for pattern in "${sensitive_patterns[@]}"; do
            if ! grep -q "$pattern" "$gitignore"; then
                echo "Gitignore missing important pattern: $pattern"
                issues=$((issues + 1))
            fi
        done
    fi
    
    return $issues
}

# Validate Starship prompt configuration
test_starship_config_validation() {
    local starship_dir="$DOTFILES_DIR/.config/starship"
    local issues=0
    
    if [[ ! -d "$starship_dir" ]]; then
        echo "Starship config directory missing"
        return 1
    fi
    
    # Check for theme files
    if [[ ! -d "$starship_dir/themes" ]]; then
        echo "Starship themes directory missing"
        return 1
    fi
    
    # Validate TOML syntax in theme files
    local toml_files=0
    while IFS= read -r -d '' toml_file; do
        toml_files=$((toml_files + 1))
        # Basic TOML validation - check for proper section format
        if ! grep -q '\[.*\]' "$toml_file"; then
            echo "Invalid TOML format in: $toml_file"
            issues=$((issues + 1))
        fi
    done < <(find "$starship_dir" -name "*.toml" -type f -print0)
    
    if [[ $toml_files -eq 0 ]]; then
        echo "No Starship theme files found"
        issues=$((issues + 1))
    fi
    
    return $issues
}

# Validate package management configuration
test_package_config_validation() {
    local brewfile="$DOTFILES_DIR/install/Brewfile"
    local issues=0
    
    if [[ ! -f "$brewfile" ]]; then
        echo "Brewfile missing"
        return 1
    fi
    
    # Check for essential packages
    local essential_packages=("git" "zsh" "neovim" "starship")
    for package in "${essential_packages[@]}"; do
        if ! grep -q "brew \"$package\"" "$brewfile"; then
            echo "Essential package missing from Brewfile: $package"
            issues=$((issues + 1))
        fi
    done
    
    # Check for potential package conflicts
    local conflicting_pairs=("vim:neovim" "bash:zsh")
    for pair in "${conflicting_pairs[@]}"; do
        IFS=':' read -r pkg1 pkg2 <<< "$pair"
        if grep -q "brew \"$pkg1\"" "$brewfile" && grep -q "brew \"$pkg2\"" "$brewfile"; then
            echo "Potential package conflict: $pkg1 and $pkg2"
            issues=$((issues + 1))
        fi
    done
    
    return $issues
}

# =============================================================================
# PERFORMANCE REGRESSION TESTING
# =============================================================================

# Test shell startup performance regression
test_startup_performance_regression() {
    local current_time baseline_time threshold
    
    # Measure current startup time (average of 5 runs)
    local total_time=0
    for i in {1..5}; do
        local single_time
        single_time=$(time (zsh -c 'exit') 2>&1 | grep real | sed 's/real[[:space:]]*//' | sed 's/s//')
        # Convert to milliseconds
        local ms_time
        ms_time=$(echo "$single_time * 1000" | bc -l 2>/dev/null || echo "1000")
        total_time=$(echo "$total_time + $ms_time" | bc -l 2>/dev/null || echo "5000")
    done
    current_time=$(echo "$total_time / 5" | bc -l 2>/dev/null || echo "1000")
    
    log_info "Current startup time: $(printf "%.0f" "$current_time")ms"
    
    # Load baseline if it exists
    if [[ -f "$PERF_BASELINE" ]]; then
        baseline_time=$(jq -r '.shell_startup_ms // 1000' "$PERF_BASELINE" 2>/dev/null || echo "1000")
        threshold=$(echo "$baseline_time * 1.3" | bc -l 2>/dev/null || echo "1300")  # 30% regression threshold
        
        log_info "Baseline startup time: $(printf "%.0f" "$baseline_time")ms"
        log_info "Regression threshold: $(printf "%.0f" "$threshold")ms"
        
        if (( $(echo "$current_time > $threshold" | bc -l 2>/dev/null || echo "0") )); then
            echo "Performance regression detected: $(printf "%.0f" "$current_time")ms > $(printf "%.0f" "$threshold")ms"
            return 1
        fi
    else
        log_warning "No performance baseline found, creating new baseline"
        mkdir -p "$ANALYTICS_DIR"
        echo "{\"shell_startup_ms\": $current_time, \"created\": \"$(date -Iseconds)\"}" > "$PERF_BASELINE"
    fi
    
    return 0
}

# Test memory usage regression
test_memory_usage_regression() {
    local current_memory baseline_memory threshold
    
    # Measure current memory usage (in KB)
    current_memory=$(ps -o rss= -p $$ | awk '{print $1}')
    
    log_info "Current memory usage: ${current_memory}KB"
    
    # Load baseline if it exists
    if [[ -f "$PERF_BASELINE" ]]; then
        baseline_memory=$(jq -r '.memory_usage_kb // 50000' "$PERF_BASELINE" 2>/dev/null || echo "50000")
        threshold=$(echo "$baseline_memory * 1.5" | bc -l 2>/dev/null || echo "75000")  # 50% regression threshold
        
        log_info "Baseline memory usage: ${baseline_memory}KB"
        
        if [[ $current_memory -gt $(printf "%.0f" "$threshold") ]]; then
            echo "Memory regression detected: ${current_memory}KB > $(printf "%.0f" "$threshold")KB"
            return 1
        fi
    else
        # Update baseline with memory info
        if [[ -f "$PERF_BASELINE" ]]; then
            jq ". + {\"memory_usage_kb\": $current_memory}" "$PERF_BASELINE" > "$PERF_BASELINE.tmp" && mv "$PERF_BASELINE.tmp" "$PERF_BASELINE"
        fi
    fi
    
    return 0
}

# Test plugin load time regression
test_plugin_performance_regression() {
    if [[ ! -f "$ANALYTICS_DIR/perf-data.csv" ]]; then
        log_warning "No performance data available for plugin regression testing"
        return 0
    fi
    
    # Get recent plugin load times
    local recent_plugin_time
    recent_plugin_time=$(grep "plugin_load" "$ANALYTICS_DIR/perf-data.csv" | tail -10 | awk -F',' '{sum+=$3} END {print sum/NR/1000000}' 2>/dev/null || echo "0")
    
    if [[ "$recent_plugin_time" == "0" ]]; then
        log_warning "No recent plugin performance data"
        return 0
    fi
    
    log_info "Recent plugin load time: $(printf "%.0f" "$recent_plugin_time")ms"
    
    # Check if plugins are loading too slowly
    if (( $(echo "$recent_plugin_time > 200" | bc -l 2>/dev/null || echo "0") )); then
        echo "Plugin performance regression: $(printf "%.0f" "$recent_plugin_time")ms > 200ms"
        return 1
    fi
    
    return 0
}

# =============================================================================
# SECURITY COMPLIANCE CHECKS
# =============================================================================

# Check for secrets in configuration files
test_security_secrets_scan() {
    local issues=0
    local secret_patterns=("password" "secret" "token" "key.*=" "api.*key" "auth.*token")
    
    log_security "Scanning for potential secrets in configuration files"
    
    # Scan all config files for secret patterns
    while IFS= read -r -d '' file; do
        for pattern in "${secret_patterns[@]}"; do
            if grep -iE "$pattern" "$file" >/dev/null 2>&1; then
                # Exclude common safe patterns and test code patterns
                if ! grep -iE "(export.*=|alias.*=|#.*$pattern|grep.*$pattern|echo.*$pattern|log.*$pattern)" "$file" >/dev/null 2>&1; then
                    # Double-check: if it's in a comment or string literal, it's probably safe
                    local matches
                    matches=$(grep -iE "$pattern" "$file")
                    if ! echo "$matches" | grep -qE "(^\s*#|\".*$pattern.*\"|'.*$pattern.*')"; then
                        echo "Potential secret found in $file: pattern '$pattern'"
                        issues=$((issues + 1))
                    fi
                fi
            fi
        done
    done < <(find "$DOTFILES_DIR" -type f \( -name "*.zsh" -o -name "*.sh" -o -name "*.toml" -o -name ".gitconfig" \) -print0)
    
    return $issues
}

# Check file permissions security
test_security_permissions() {
    local issues=0
    
    log_security "Checking file permissions"
    
    # Check for overly permissive files
    while IFS= read -r -d '' file; do
        local perms
        perms=$(stat -f "%A" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null || echo "644")
        
        # Config files shouldn't be world-writable
        if [[ "$perms" =~ .*[2367].$ ]]; then
            echo "Insecure permissions on $file: $perms (world-writable)"
            issues=$((issues + 1))
        fi
        
        # Executable files should have proper permissions
        if [[ "$file" == *.sh ]] && [[ ! "$perms" =~ .*[157].$ ]]; then
            echo "Non-executable script: $file ($perms)"
            issues=$((issues + 1))
        fi
    done < <(find "$DOTFILES_DIR" -type f \( -name "*.zsh" -o -name "*.sh" -o -name "*.toml" \) -print0)
    
    return $issues
}

# Check for secure shell configuration
test_security_shell_config() {
    local issues=0
    local zsh_config="$DOTFILES_DIR/.config/zsh"
    
    log_security "Checking shell security configuration"
    
    # Check for dangerous PATH modifications
    if grep -E "PATH.*:\.:" "$zsh_config"/*.zsh >/dev/null 2>&1; then
        echo "Dangerous PATH configuration: current directory in PATH"
        issues=$((issues + 1))
    fi
    
    # Check for insecure command history settings
    if [[ -z "${HISTFILE:-}" ]]; then
        echo "History file not explicitly configured"
        issues=$((issues + 1))
    fi
    
    # Check for umask setting
    if ! grep -q "umask" "$zsh_config"/*.zsh 2>/dev/null; then
        echo "No umask setting found (security best practice)"
        issues=$((issues + 1))
    fi
    
    return $issues
}

# Check Git security configuration
test_security_git_config() {
    local issues=0
    local git_config="$DOTFILES_DIR/git/.gitconfig"
    
    log_security "Checking Git security configuration"
    
    if [[ ! -f "$git_config" ]]; then
        echo "Git config file missing"
        return 1
    fi
    
    # Check for GPG signing configuration
    if ! grep -q "signingkey\|gpgsign" "$git_config"; then
        echo "Git commit signing not configured (recommended for security)"
        issues=$((issues + 1))
    fi
    
    # Check for secure URL protocols
    if grep -E "url.*http://" "$git_config" >/dev/null 2>&1; then
        echo "Insecure HTTP URLs found in Git config"
        issues=$((issues + 1))
    fi
    
    # Check for credential helper configuration
    if ! grep -q "credential" "$git_config"; then
        echo "Git credential helper not configured"
        issues=$((issues + 1))
    fi
    
    return $issues
}

# Check for dependency security issues
test_security_dependencies() {
    local issues=0
    
    log_security "Checking dependency security"
    
    # Check if we're downloading from secure sources
    local brewfile="$DOTFILES_DIR/install/Brewfile"
    if [[ -f "$brewfile" ]]; then
        # Check for insecure tap sources
        if grep -E "tap.*http://" "$brewfile" >/dev/null 2>&1; then
            echo "Insecure HTTP tap sources in Brewfile"
            issues=$((issues + 1))
        fi
        
        # Check for unofficial taps (security warning)
        local unofficial_taps
        unofficial_taps=$(grep "^tap" "$brewfile" | grep -cv "homebrew/" || echo 0)
        if [[ $unofficial_taps -gt 3 ]]; then
            echo "Many unofficial taps detected ($unofficial_taps) - verify sources"
            issues=$((issues + 1))
        fi
    fi
    
    return $issues
}

# Create security baseline
create_security_baseline() {
    log_info "Creating security baseline"
    mkdir -p "$ANALYTICS_DIR"
    
    local baseline
    baseline="{
        \"created\": \"$(date -Iseconds)\",
        \"file_count\": $(find "$DOTFILES_DIR" -type f | wc -l),
        \"script_count\": $(find "$DOTFILES_DIR" -name "*.sh" -type f | wc -l),
        \"config_files\": $(find "$DOTFILES_DIR" -name "*.zsh" -o -name "*.toml" | wc -l)
    }"
    
    echo "$baseline" > "$SECURITY_BASELINE"
    log_success "Security baseline created"
}

# =============================================================================
# TEST RUNNERS
# =============================================================================

# Run configuration validation tests
run_config_validation_tests() {
    log_info "🔧 Running Configuration Validation Tests"
    echo "============================================="
    
    run_test "Zsh Configuration Validation" test_zsh_config_validation
    run_test "Neovim Configuration Validation" test_neovim_config_validation
    run_test "Git Configuration Validation" test_git_config_validation
    run_test "Starship Configuration Validation" test_starship_config_validation
    run_test "Package Configuration Validation" test_package_config_validation
}

# Run performance regression tests
run_performance_regression_tests() {
    log_info "⚡ Running Performance Regression Tests"
    echo "========================================"
    
    run_test "Shell Startup Performance" test_startup_performance_regression
    run_test "Memory Usage Regression" test_memory_usage_regression true  # Warning only
    run_test "Plugin Performance Regression" test_plugin_performance_regression true  # Warning only
}

# Run security compliance tests
run_security_compliance_tests() {
    log_info "🔒 Running Security Compliance Tests"
    echo "====================================="
    
    # Create baseline if it doesn't exist
    if [[ ! -f "$SECURITY_BASELINE" ]]; then
        create_security_baseline
    fi
    
    run_test "Secrets Scanning" test_security_secrets_scan
    run_test "File Permissions Security" test_security_permissions
    run_test "Shell Configuration Security" test_security_shell_config
    run_test "Git Security Configuration" test_security_git_config true  # Warning only
    run_test "Dependency Security" test_security_dependencies true  # Warning only
}

# Run all advanced tests
run_all_advanced_tests() {
    log_info "🚀 Starting Advanced Testing Suite"
    echo "=================================="
    echo "Testing directory: $DOTFILES_DIR"
    echo
    
    run_config_validation_tests
    echo
    run_performance_regression_tests
    echo
    run_security_compliance_tests
    
    # Summary
    echo
    echo "======================================="
    echo -e "${BLUE}Advanced Test Summary:${NC}"
    echo -e "  Total: $TESTS_RUN"
    echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "  ${YELLOW}Warnings: $WARNINGS${NC}"
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
        echo -e "\n${RED}Some advanced tests failed. Please review the output above.${NC}"
        return 1
    else
        echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
        echo -e "\n${GREEN}All advanced tests passed! 🎉${NC}"
        if [[ $WARNINGS -gt 0 ]]; then
            echo -e "${YELLOW}Note: $WARNINGS warnings were found - consider addressing them.${NC}"
        fi
        return 0
    fi
}

# Show help
show_help() {
    echo "Advanced Testing Framework"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  config              Run configuration validation tests only"
    echo "  performance         Run performance regression tests only"
    echo "  security            Run security compliance tests only"
    echo "  all                 Run all advanced tests (default)"
    echo "  baseline            Create new performance and security baselines"
    echo "  --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 config           # Validate all configuration files"
    echo "  $0 performance      # Check for performance regressions"
    echo "  $0 security         # Run security compliance checks"
    echo "  $0 baseline         # Create new baselines for future tests"
}

# Main function
main() {
    # Ensure dependencies are available
    if ! command -v bc >/dev/null 2>&1; then
        log_error "bc (calculator) is required for performance tests"
        exit 1
    fi
    
    case "${1:-all}" in
        config)
            run_config_validation_tests
            ;;
        performance)
            run_performance_regression_tests
            ;;
        security)
            run_security_compliance_tests
            ;;
        all)
            run_all_advanced_tests
            ;;
        baseline)
            create_security_baseline
            log_info "Run performance tests to create performance baseline"
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