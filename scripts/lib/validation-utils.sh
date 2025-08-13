#!/usr/bin/env bash

# Configuration validation utilities
# This file consolidates validation patterns used across multiple scripts

# Source common utilities (only if not already sourced)
if [[ -z "${_COMMON_SOURCED:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # shellcheck source=scripts/lib/common.sh
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/common.sh"
fi

# Validation counter variables
VALIDATIONS_PASSED=0
VALIDATIONS_FAILED=0
VALIDATIONS_WARNINGS=0

# Reset validation counters
reset_validation_counters() {
    VALIDATIONS_PASSED=0
    VALIDATIONS_FAILED=0
    VALIDATIONS_WARNINGS=0
}

# Get validation summary
get_validation_summary() {
    local total=$((VALIDATIONS_PASSED + VALIDATIONS_FAILED + VALIDATIONS_WARNINGS))
    echo "Validation Summary: $VALIDATIONS_PASSED passed, $VALIDATIONS_FAILED failed, $VALIDATIONS_WARNINGS warnings (Total: $total)"
}

# Validate Zsh configuration syntax
validate_zsh_syntax() {
    local config_file="$1"
    local description="${2:-Zsh config file}"
    
    if [[ ! -f "$config_file" ]]; then
        log_error "$description: File not found - $config_file"
        ((VALIDATIONS_FAILED++))
        return 1
    fi
    
    if zsh -n "$config_file" 2>/dev/null; then
        log_success "$description: Syntax is valid"
        ((VALIDATIONS_PASSED++))
        return 0
    else
        log_error "$description: Syntax error detected"
        ((VALIDATIONS_FAILED++))
        return 1
    fi
}

# Check if symlink points to expected target
check_symlink_target() {
    local link_path="$1"
    local expected_target="$2"
    local description="${3:-Symlink}"
    
    if [[ ! -L "$link_path" ]]; then
        if [[ -e "$link_path" ]]; then
            log_warning "$description: $link_path exists but is not a symlink"
            ((VALIDATIONS_WARNINGS++))
        else
            log_error "$description: $link_path does not exist"
            ((VALIDATIONS_FAILED++))
        fi
        return 1
    fi
    
    local actual_target
    actual_target=$(readlink "$link_path")
    
    if [[ "$actual_target" == "$expected_target" ]]; then
        log_success "$description: $link_path → $expected_target"
        ((VALIDATIONS_PASSED++))
        return 0
    else
        log_error "$description: $link_path → $actual_target (expected: $expected_target)"
        ((VALIDATIONS_FAILED++))
        return 1
    fi
}

# Check if file exists
check_file_exists() {
    local file_path="$1"
    local description="${2:-File}"
    
    if [[ -f "$file_path" ]]; then
        log_success "$description: $file_path exists"
        ((VALIDATIONS_PASSED++))
        return 0
    else
        log_error "$description: $file_path not found"
        ((VALIDATIONS_FAILED++))
        return 1
    fi
}

# Check if directory exists
check_directory_exists() {
    local dir_path="$1"
    local description="${2:-Directory}"
    
    if [[ -d "$dir_path" ]]; then
        log_success "$description: $dir_path exists"
        ((VALIDATIONS_PASSED++))
        return 0
    else
        log_error "$description: $dir_path not found"
        ((VALIDATIONS_FAILED++))
        return 1
    fi
}

# Validate configuration directory structure
validate_config_directory() {
    local config_dir="$1"
    local description="${2:-Configuration directory}"
    shift 2
    local required_files=("$@")
    
    if ! check_directory_exists "$config_dir" "$description"; then
        return 1
    fi
    
    local missing_files=()
    for file in "${required_files[@]}"; do
        local file_path="$config_dir/$file"
        if [[ ! -f "$file_path" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -eq 0 ]]; then
        log_success "$description: All required files present"
        ((VALIDATIONS_PASSED++))
        return 0
    else
        log_error "$description: Missing files - ${missing_files[*]}"
        ((VALIDATIONS_FAILED++))
        return 1
    fi
}

# Check if command exists and optionally validate version
check_command_with_version() {
    local command_name="$1"
    local description="${2:-$command_name}"
    local min_version="${3:-}"
    
    if ! check_command_exists "$command_name"; then
        log_error "$description: Command not found"
        ((VALIDATIONS_FAILED++))
        return 1
    fi
    
    local version=""
    case "$command_name" in
        git) version=$(git --version 2>/dev/null | sed 's/git version //') ;;
        brew) version=$(brew --version 2>/dev/null | head -1 | sed 's/Homebrew //') ;;
        zsh) version=$(zsh --version 2>/dev/null | sed 's/zsh //') ;;
        nvim) version=$(nvim --version 2>/dev/null | head -1 | sed 's/NVIM v//') ;;
        *) version="Available" ;;
    esac
    
    if [[ -n "$min_version" ]] && [[ "$version" != "Available" ]]; then
        if version_gte "$version" "$min_version"; then
            log_success "$description: $command_name v$version (>= $min_version)"
            ((VALIDATIONS_PASSED++))
            return 0
        else
            log_warning "$description: $command_name v$version (< $min_version required)"
            ((VALIDATIONS_WARNINGS++))
            return 1
        fi
    else
        log_success "$description: $command_name ($version)"
        ((VALIDATIONS_PASSED++))
        return 0
    fi
}

# Validate shell configuration
validate_shell_config() {
    local shell_name="$1"
    local config_file="$2"
    local description="${3:-$shell_name configuration}"
    
    # Check if shell is available
    if ! check_command_exists "$shell_name"; then
        log_error "$description: $shell_name not installed"
        ((VALIDATIONS_FAILED++))
        return 1
    fi
    
    # Check if config file exists
    if ! check_file_exists "$config_file" "$description file"; then
        return 1
    fi
    
    # Validate syntax for known shells
    case "$shell_name" in
        zsh)
            validate_zsh_syntax "$config_file" "$description"
            ;;
        bash)
            if bash -n "$config_file" 2>/dev/null; then
                log_success "$description: Syntax is valid"
                ((VALIDATIONS_PASSED++))
                return 0
            else
                log_error "$description: Syntax error detected"
                ((VALIDATIONS_FAILED++))
                return 1
            fi
            ;;
        *)
            log_success "$description: File exists (syntax not validated)"
            ((VALIDATIONS_PASSED++))
            return 0
            ;;
    esac
}

# Check Git configuration
validate_git_config() {
    local git_config_name="$1"
    local description="${2:-Git $git_config_name}"
    
    local config_value
    config_value=$(git config --global "$git_config_name" 2>/dev/null || echo "")
    
    if [[ -n "$config_value" ]]; then
        log_success "$description: '$config_value'"
        ((VALIDATIONS_PASSED++))
        return 0
    else
        log_warning "$description: Not configured"
        ((VALIDATIONS_WARNINGS++))
        return 1
    fi
}

# Validate permission settings
check_file_permissions() {
    local file_path="$1"
    local expected_perms="$2"
    local description="${3:-File permissions}"
    
    if [[ ! -e "$file_path" ]]; then
        log_error "$description: $file_path does not exist"
        ((VALIDATIONS_FAILED++))
        return 1
    fi
    
    local actual_perms
    actual_perms=$(stat -f "%A" "$file_path" 2>/dev/null || stat -c "%a" "$file_path" 2>/dev/null)
    
    if [[ "$actual_perms" == "$expected_perms" ]]; then
        log_success "$description: $file_path has correct permissions ($expected_perms)"
        ((VALIDATIONS_PASSED++))
        return 0
    else
        log_warning "$description: $file_path has permissions $actual_perms (expected: $expected_perms)"
        ((VALIDATIONS_WARNINGS++))
        return 1
    fi
}

# Check if default shell is set correctly
validate_default_shell() {
    local expected_shell="$1"
    local description="${2:-Default shell}"
    
    if [[ "$SHELL" == *"$expected_shell"* ]]; then
        log_success "$description: $expected_shell is set as default"
        ((VALIDATIONS_PASSED++))
        return 0
    else
        log_warning "$description: Current shell is $SHELL, expected $expected_shell"
        ((VALIDATIONS_WARNINGS++))
        return 1
    fi
}

# Validate JSON/TOML configuration files
validate_config_file_syntax() {
    local config_file="$1"
    local file_type="${2:-auto}"
    local description="${3:-Configuration file}"
    
    if [[ ! -f "$config_file" ]]; then
        log_error "$description: File not found - $config_file"
        ((VALIDATIONS_FAILED++))
        return 1
    fi
    
    # Auto-detect file type if not specified
    if [[ "$file_type" == "auto" ]]; then
        case "$config_file" in
            *.json) file_type="json" ;;
            *.toml) file_type="toml" ;;
            *.yaml|*.yml) file_type="yaml" ;;
            *) file_type="unknown" ;;
        esac
    fi
    
    case "$file_type" in
        json)
            if command -v jq >/dev/null 2>&1; then
                if jq empty "$config_file" 2>/dev/null; then
                    log_success "$description: Valid JSON syntax"
                    ((VALIDATIONS_PASSED++))
                    return 0
                else
                    log_error "$description: Invalid JSON syntax"
                    ((VALIDATIONS_FAILED++))
                    return 1
                fi
            else
                log_success "$description: JSON file exists (jq not available for validation)"
                ((VALIDATIONS_PASSED++))
                return 0
            fi
            ;;
        toml)
            # Basic TOML validation - check for obvious syntax errors
            if grep -E '^[[:space:]]*\[[[:space:]]*\][[:space:]]*$' "$config_file" >/dev/null; then
                log_error "$description: Invalid TOML - empty section header"
                ((VALIDATIONS_FAILED++))
                return 1
            else
                log_success "$description: TOML file syntax appears valid"
                ((VALIDATIONS_PASSED++))
                return 0
            fi
            ;;
        *)
            log_success "$description: File exists"
            ((VALIDATIONS_PASSED++))
            return 0
            ;;
    esac
}