#!/usr/bin/env bash

# Automated testing framework for dotfiles
# Tests configuration syntax, symlinks, and functionality

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
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

# Test functions
test_zsh_syntax() {
    local zshrc="$HOME/.zshrc"
    if [[ ! -f "$zshrc" ]]; then
        echo "No .zshrc found at $zshrc"
        return 1
    fi

    # Test zsh syntax without executing
    if ! zsh -n "$zshrc" 2>/dev/null; then
        echo "Syntax error in $zshrc"
        return 1
    fi

    return 0
}

test_modular_configs_exist() {
    local config_dir="$HOME/.config/zsh"
    local configs=("aliases.zsh" "exports.zsh" "functions.zsh" "misc.zsh" "path.zsh")

    for config in "${configs[@]}"; do
        if [[ ! -f "$config_dir/$config" ]]; then
            echo "Missing modular config: $config_dir/$config"
            return 1
        fi
    done

    return 0
}

test_modular_configs_syntax() {
    local config_dir="$HOME/.config/zsh"
    local configs=("aliases.zsh" "exports.zsh" "functions.zsh" "misc.zsh" "path.zsh")

    for config in "${configs[@]}"; do
        local config_file="$config_dir/$config"
        if [[ -f "$config_file" ]]; then
            if ! zsh -n "$config_file" 2>/dev/null; then
                echo "Syntax error in $config_file"
                return 1
            fi
        fi
    done

    return 0
}

test_private_config_setup() {
    local private_config="$HOME/.config/zsh/private.zsh"

    # Private config should exist or be mentioned in docs
    if [[ ! -f "$private_config" ]]; then
        log_warning "Private config not found at $private_config (this is normal for new setups)"
        # Check if it would be sourced correctly if it existed
        if ! grep -q "private.zsh" "$HOME/.zshrc"; then
            echo ".zshrc doesn't source private.zsh"
            return 1
        fi
    else
        # If it exists, test syntax
        if ! zsh -n "$private_config" 2>/dev/null; then
            echo "Syntax error in $private_config"
            return 1
        fi
    fi

    return 0
}

test_essential_commands() {
    local commands=("git" "vim" "zsh")

    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Essential command not found: $cmd"
            return 1
        fi
    done

    return 0
}

test_zsh_plugins() {
    # Check if znap is installed
    if [[ ! -d "$HOME/.zsh/znap" ]]; then
        echo "znap plugin manager not found at ~/.zsh/znap"
        return 1
    fi

    # Check if znap plugins file exists
    if [[ ! -f "$HOME/.znap-plugins.zsh" ]]; then
        echo "znap plugins file not found at ~/.znap-plugins.zsh"
        return 1
    fi

    # Test znap plugins file syntax
    if ! zsh -n "$HOME/.znap-plugins.zsh" 2>/dev/null; then
        echo "Syntax error in ~/.znap-plugins.zsh"
        return 1
    fi

    return 0
}

test_starship_config() {
    # Check if starship is installed
    if ! command -v starship &> /dev/null; then
        echo "starship not found"
        return 1
    fi

    # Check if starship config exists and is readable
    local config_file="$HOME/.config/starship.toml"
    if [[ ! -f "$config_file" ]]; then
        echo "starship config file not found at $config_file"
        return 1
    fi

    # Basic TOML syntax validation (check for basic structure)
    if ! grep -q '\[' "$config_file"; then
        echo "starship config appears to be invalid (no TOML sections found)"
        return 1
    fi

    return 0
}

test_vim_config() {
    local vimrc="$HOME/.vimrc"

    # Check if vim config exists
    if [[ ! -f "$vimrc" ]] && [[ ! -f "$HOME/.vim/vimrc" ]]; then
        echo "No vim configuration found"
        return 1
    fi

    # Basic vim syntax check (if vimrc exists)
    if [[ -f "$vimrc" ]]; then
        # Check for basic syntax by looking for vim-specific patterns
        if ! grep -q "set\|let\|map\|autocmd" "$vimrc"; then
            echo "vimrc appears to be empty or invalid"
            return 1
        fi
    fi

    return 0
}

test_git_config() {
    # Check if git is configured
    if ! git config --get user.name &>/dev/null; then
        echo "Git user.name not configured"
        return 1
    fi

    if ! git config --get user.email &>/dev/null; then
        echo "Git user.email not configured"
        return 1
    fi

    return 0
}

test_homebrew_integration() {
    # Only test on macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &> /dev/null; then
            echo "Homebrew not found (expected on macOS)"
            return 1
        fi
    fi

    return 0
}

test_path_configuration() {
    # Check if essential directories are in PATH
    local essential_paths=("$HOME/bin" "/usr/local/bin")

    for path_dir in "${essential_paths[@]}"; do
        if [[ -d "$path_dir" ]] && [[ ":$PATH:" != *":$path_dir:"* ]]; then
            echo "Essential directory not in PATH: $path_dir"
            return 1
        fi
    done

    return 0
}

# Performance tests
test_shell_startup_performance() {
    local startup_time
    startup_time=$(time (zsh -c 'exit') 2>&1 | grep real | awk '{print $2}')

    log_info "Shell startup time: $startup_time"

    # Extract seconds (rough check - startup should be under 2 seconds for good UX)
    if [[ "$startup_time" =~ ([0-9]+)\.([0-9]+)s ]]; then
        local seconds=${BASH_REMATCH[1]}
        if [[ $seconds -gt 2 ]]; then
            echo "Shell startup is slow: ${startup_time} (>2s)"
            return 1
        fi
    fi

    return 0
}

# Main test runner
run_all_tests() {
    log_info "Starting dotfiles test suite..."
    echo "========================================="

    # Core configuration tests
    run_test "Zsh syntax validation" test_zsh_syntax
    run_test "Modular configs exist" test_modular_configs_exist
    run_test "Modular configs syntax" test_modular_configs_syntax
    run_test "Private config setup" test_private_config_setup

    # Dependency tests
    run_test "Essential commands available" test_essential_commands
    run_test "Zsh plugins configuration" test_zsh_plugins
    run_test "Starship prompt configuration" test_starship_config
    run_test "Vim configuration" test_vim_config
    run_test "Git configuration" test_git_config
    run_test "Homebrew integration" test_homebrew_integration
    run_test "PATH configuration" test_path_configuration

    # Performance tests
    run_test "Shell startup performance" test_shell_startup_performance

    # Summary
    echo -e "\n========================================="
    echo -e "${BLUE}Test Summary:${NC}"
    echo -e "  Total: $TESTS_RUN"
    echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
        echo -e "\n${RED}Some tests failed. Please review the output above.${NC}"
        return 1
    else
        echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
        echo -e "\n${GREEN}All tests passed! 🎉${NC}"
        return 0
    fi
}

# Command line interface
show_help() {
    echo "Dotfiles Test Suite"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help          Show this help message"
    echo "  --syntax-only   Run only syntax validation tests"
    echo "  --perf-only     Run only performance tests"
    echo "  --quick         Run essential tests only"
    echo ""
}

main() {
    case "${1:-}" in
        --help)
            show_help
            exit 0
            ;;
        --syntax-only)
            run_test "Zsh syntax validation" test_zsh_syntax
            run_test "Modular configs syntax" test_modular_configs_syntax
            ;;
        --perf-only)
            run_test "Shell startup performance" test_shell_startup_performance
            ;;
        --quick)
            run_test "Zsh syntax validation" test_zsh_syntax
            run_test "Essential commands available" test_essential_commands
            run_test "Modular configs exist" test_modular_configs_exist
            ;;
        *)
            run_all_tests
            ;;
    esac
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
