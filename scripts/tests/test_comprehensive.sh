#!/usr/bin/env bash

# Comprehensive Test Runner
# Orchestrates all testing components: basic, CI, and advanced tests

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test suite counters
SUITES_RUN=0
SUITES_PASSED=0
SUITES_FAILED=0

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Run a test suite and track results
run_test_suite() {
    local suite_name="$1"
    local test_script="$2"
    local suite_args="${3:-}"
    
    echo
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🧪 Running Test Suite: ${suite_name}${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    SUITES_RUN=$((SUITES_RUN + 1))
    
    if [[ ! -f "$test_script" ]]; then
        log_error "Test script not found: $test_script"
        SUITES_FAILED=$((SUITES_FAILED + 1))
        return 1
    fi
    
    if bash "$test_script" $suite_args; then
        log_success "✅ $suite_name completed successfully"
        SUITES_PASSED=$((SUITES_PASSED + 1))
        return 0
    else
        log_error "❌ $suite_name failed"
        SUITES_FAILED=$((SUITES_FAILED + 1))
        return 1
    fi
}

# Run basic dotfiles tests
run_basic_tests() {
    run_test_suite "Basic Dotfiles Tests" "$SCRIPT_DIR/test_dotfiles.sh"
}

# Run CI tests
run_ci_tests() {
    run_test_suite "CI Tests" "$SCRIPT_DIR/test_ci.sh"
}

# Run advanced tests
run_advanced_tests() {
    run_test_suite "Advanced Tests" "$SCRIPT_DIR/test_advanced.sh" "all"
}

# Run configuration validation only
run_config_tests() {
    run_test_suite "Configuration Validation" "$SCRIPT_DIR/test_advanced.sh" "config"
}

# Run performance tests only
run_performance_tests() {
    run_test_suite "Performance Regression Tests" "$SCRIPT_DIR/test_advanced.sh" "performance"
}

# Run security tests only
run_security_tests() {
    run_test_suite "Security Compliance Tests" "$SCRIPT_DIR/test_advanced.sh" "security"
}

# Run quick validation suite (essential tests only)
run_quick_tests() {
    echo -e "${CYAN}🚀 Running Quick Test Suite${NC}"
    echo "This runs essential validation tests for rapid feedback"
    echo
    
    run_test_suite "Quick Basic Tests" "$SCRIPT_DIR/test_dotfiles.sh" "--quick"
    run_test_suite "Configuration Validation" "$SCRIPT_DIR/test_advanced.sh" "config"
}

# Run full comprehensive test suite
run_full_tests() {
    echo -e "${CYAN}🚀 Running Full Comprehensive Test Suite${NC}"
    echo "This includes all available tests: basic, CI, and advanced"
    echo
    
    local start_time
    start_time=$(date +%s)
    
    # Run all test suites
    run_basic_tests
    run_ci_tests
    run_advanced_tests
    
    local end_time duration
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📊 Comprehensive Test Summary${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  Total Test Suites: $SUITES_RUN"
    echo -e "  ${GREEN}✅ Passed: $SUITES_PASSED${NC}"
    echo -e "  ${RED}❌ Failed: $SUITES_FAILED${NC}"
    echo -e "  ⏱️  Duration: ${duration}s"
    echo
    
    if [[ $SUITES_FAILED -gt 0 ]]; then
        echo -e "${RED}💥 Some test suites failed. Please review the output above for details.${NC}"
        echo -e "${YELLOW}💡 Try running individual test suites to isolate issues:${NC}"
        echo -e "  ${CYAN}$0 basic${NC}     - Run basic dotfiles tests"
        echo -e "  ${CYAN}$0 advanced${NC}  - Run advanced tests"
        echo -e "  ${CYAN}$0 config${NC}    - Run configuration validation"
        return 1
    else
        echo -e "${GREEN}🎉 All test suites passed successfully!${NC}"
        echo -e "${CYAN}✨ Your dotfiles configuration is validated and secure.${NC}"
        return 0
    fi
}

# Run pre-commit tests (fast essential checks)
run_precommit_tests() {
    echo -e "${CYAN}🔍 Running Pre-Commit Tests${NC}"
    echo "Fast essential checks before committing changes"
    echo
    
    # Only run syntax and basic validation
    run_test_suite "Syntax Validation" "$SCRIPT_DIR/test_dotfiles.sh" "--syntax-only"
    run_test_suite "CI Tests" "$SCRIPT_DIR/test_ci.sh"
    run_test_suite "Configuration Validation" "$SCRIPT_DIR/test_advanced.sh" "config"
}

# Create test report
generate_test_report() {
    local output_file="${1:-$HOME/dotfiles-test-report.txt}"
    
    log_info "Generating comprehensive test report..."
    
    {
        echo "Dotfiles Comprehensive Test Report"
        echo "Generated: $(date)"
        echo "=================================="
        echo
        
        echo "SYSTEM INFORMATION:"
        echo "- OS: $(uname -s) $(uname -r)"
        echo "- Shell: $SHELL"
        echo "- Date: $(date)"
        echo
        
        echo "TEST EXECUTION:"
        run_full_tests 2>&1
        
    } > "$output_file"
    
    log_success "Test report saved to: $output_file"
}

# Show help
show_help() {
    echo "Comprehensive Test Runner"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Test Suites:"
    echo "  full                Run complete test suite (basic + CI + advanced)"
    echo "  basic               Run basic dotfiles functionality tests"
    echo "  ci                  Run CI-specific tests (syntax, structure)"
    echo "  advanced            Run advanced tests (config + performance + security)"
    echo "  quick               Run quick validation tests (essential only)"
    echo "  precommit           Run pre-commit validation tests"
    echo ""
    echo "Individual Test Categories:"
    echo "  config              Run configuration validation tests only"
    echo "  performance         Run performance regression tests only"
    echo "  security            Run security compliance tests only"
    echo ""
    echo "Utilities:"
    echo "  report [file]       Generate comprehensive test report"
    echo "  --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                  # Run full test suite (default)"
    echo "  $0 quick            # Quick validation for development"
    echo "  $0 precommit        # Pre-commit checks"
    echo "  $0 config           # Validate configuration only"
    echo "  $0 report test.txt  # Generate test report"
    echo ""
    echo "Exit Codes:"
    echo "  0    All tests passed"
    echo "  1    Some tests failed"
    echo "  2    Script error or invalid arguments"
}

# Validate dependencies
check_dependencies() {
    local missing_deps=()
    local required_deps=("zsh" "bash" "git")
    
    for dep in "${required_deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        echo "Please install missing dependencies and try again."
        exit 2
    fi
    
    # Check for optional but recommended dependencies
    local recommended_deps=("jq" "bc")
    local missing_recommended=()
    
    for dep in "${recommended_deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_recommended+=("$dep")
        fi
    done
    
    if [[ ${#missing_recommended[@]} -gt 0 ]]; then
        log_warning "Missing recommended dependencies: ${missing_recommended[*]}"
        log_warning "Some advanced tests may not work properly"
    fi
}

# Main function
main() {
    # Check dependencies first
    check_dependencies
    
    case "${1:-full}" in
        full|"")
            run_full_tests
            ;;
        basic)
            run_basic_tests
            ;;
        ci)
            run_ci_tests
            ;;
        advanced)
            run_advanced_tests
            ;;
        config)
            run_config_tests
            ;;
        performance)
            run_performance_tests
            ;;
        security)
            run_security_tests
            ;;
        quick)
            run_quick_tests
            ;;
        precommit)
            run_precommit_tests
            ;;
        report)
            generate_test_report "$2"
            ;;
        --help|help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown command: $1"
            echo ""
            show_help
            exit 2
            ;;
    esac
}

# Run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi