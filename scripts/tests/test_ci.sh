#!/usr/bin/env bash

# CI-specific test suite for GitHub Actions
# Tests source files directly without requiring local installation

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
# YELLOW='\033[1;33m'  # Reserved for future use
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

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

# Test framework functions
run_test() {
    local test_name="$1"
    local test_function="$2"

    echo -e "\n${BLUE}Running:${NC} $test_name"
    TESTS_RUN=$((TESTS_RUN + 1))

    if $test_function; then
        log_success "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "$test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Test source file syntax
test_source_zsh_syntax() {
    local zshrc="$DOTFILES_DIR/.config/zsh/.zshrc"
    
    if [[ ! -f "$zshrc" ]]; then
        echo "Source .zshrc not found at $zshrc"
        return 1
    fi

    # Test zsh syntax without executing
    if ! zsh -n "$zshrc" 2>/dev/null; then
        echo "Syntax error in source $zshrc"
        return 1
    fi

    return 0
}

# Test modular config syntax
test_source_modular_syntax() {
    local source_dir="$DOTFILES_DIR/.config/zsh"
    local configs=("aliases.zsh" "exports.zsh" "functions.zsh" "misc.zsh" "path.zsh")

    for config in "${configs[@]}"; do
        local config_file="$source_dir/$config"
        
        if [[ ! -f "$config_file" ]]; then
            echo "Source config file not found: $config_file"
            return 1
        fi
        
        # Test syntax
        if ! zsh -n "$config_file" 2>/dev/null; then
            echo "Syntax error in $config_file"
            return 1
        fi
    done

    return 0
}

# Test znap plugins file syntax
test_znap_plugins_syntax() {
    local plugins_file="$DOTFILES_DIR/.config/zsh/.znap-plugins.zsh"
    
    if [[ ! -f "$plugins_file" ]]; then
        echo "znap plugins file not found at $plugins_file"
        return 1
    fi

    # Test syntax
    if ! zsh -n "$plugins_file" 2>/dev/null; then
        echo "Syntax error in $plugins_file"
        return 1
    fi

    return 0
}

# Test shell scripts syntax
test_shell_scripts_syntax() {
    local scripts_found=false
    
    # Test all shell scripts in the repository
    while IFS= read -r -d '' script; do
        scripts_found=true
        if ! bash -n "$script" 2>/dev/null; then
            echo "Bash syntax error in $script"
            return 1
        fi
    done < <(find "$DOTFILES_DIR" -name "*.sh" -type f -print0)
    
    if [[ "$scripts_found" == false ]]; then
        echo "No shell scripts found to test"
        return 1
    fi
    
    return 0
}

# Test essential directories exist
test_directory_structure() {
    local required_dirs=(".config" "git" "install" "scripts" "bin")
    local required_config_dirs=("zsh" "nvim" "starship" "atuin")
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$DOTFILES_DIR/$dir" ]]; then
            echo "Required directory missing: $dir"
            return 1
        fi
    done
    
    # Check .config subdirectories
    for config_dir in "${required_config_dirs[@]}"; do
        if [[ ! -d "$DOTFILES_DIR/.config/$config_dir" ]]; then
            echo "Required .config directory missing: .config/$config_dir"
            return 1
        fi
    done
    
    return 0
}

# Test essential files exist
test_essential_files() {
    local required_files=(
        ".config/zsh/.zshrc"
        ".config/zsh/.znap-plugins.zsh"
        "git/.gitconfig"
        "git/.gitignore"
        ".config/nvim/.ideavimrc"
        "README.md"
        "Makefile"
        "scripts/setup.sh"
        "scripts/symlink.sh"
        "scripts/validate.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$DOTFILES_DIR/$file" ]]; then
            echo "Required file missing: $file"
            return 1
        fi
    done
    
    return 0
}

# Test Brewfile syntax
test_brewfile_syntax() {
    local brewfile="$DOTFILES_DIR/install/Brewfile"
    
    if [[ ! -f "$brewfile" ]]; then
        echo "Brewfile not found at $brewfile"
        return 1
    fi
    
    # Check for basic Brewfile syntax (brew/cask/tap/mas commands)
    if ! grep -E '^(brew|cask|tap|mas)' "$brewfile" > /dev/null; then
        echo "Brewfile appears invalid - no valid brew commands found"
        return 1
    fi
    
    # Check Ruby syntax if ruby is available
    if command -v ruby > /dev/null 2>&1; then
        if ! ruby -c "$brewfile" > /dev/null 2>&1; then
            echo "Brewfile has Ruby syntax errors"
            return 1
        fi
    fi
    
    return 0
}

# Run CI test suite
run_ci_tests() {
    log_info "Starting CI test suite for dotfiles..."
    echo "Testing directory: $DOTFILES_DIR"
    echo "========================================="

    run_test "Directory structure" test_directory_structure
    run_test "Essential files exist" test_essential_files
    run_test "Source .zshrc syntax" test_source_zsh_syntax
    run_test "Modular configs syntax" test_source_modular_syntax
    run_test "znap plugins syntax" test_znap_plugins_syntax
    run_test "Shell scripts syntax" test_shell_scripts_syntax
    run_test "Brewfile syntax" test_brewfile_syntax

    # Summary
    echo -e "\n========================================="
    echo -e "${BLUE}CI Test Summary:${NC}"
    echo -e "  Total: $TESTS_RUN"
    echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
        echo -e "\n${RED}Some CI tests failed. Please review the output above.${NC}"
        return 1
    else
        echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
        echo -e "\n${GREEN}All CI tests passed! 🎉${NC}"
        return 0
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_ci_tests
fi