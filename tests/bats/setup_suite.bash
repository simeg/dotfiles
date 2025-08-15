#!/usr/bin/env bash

# Bats test suite setup
# This file runs once before all tests in the suite

setup_suite() {
    # Load shared libraries
    export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts"
    export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

    # Source shared libraries if they exist
    if [[ -f "$SCRIPT_DIR/lib/common.sh" ]]; then
        # shellcheck source=../../scripts/lib/common.sh
        source "$SCRIPT_DIR/lib/common.sh"
    fi

    if [[ -f "$SCRIPT_DIR/lib/validation-utils.sh" ]]; then
        # shellcheck source=../../scripts/lib/validation-utils.sh
        source "$SCRIPT_DIR/lib/validation-utils.sh"
    fi

    # Set test environment variables
    export TESTS_RUN=0
    export TESTS_PASSED=0
    export TESTS_FAILED=0
    export WARNINGS=0

    # Analytics and baseline paths
    export ANALYTICS_DIR="$HOME/.config/dotfiles"
    export PERF_BASELINE="$ANALYTICS_DIR/perf-baseline.json"
    export SECURITY_BASELINE="$ANALYTICS_DIR/security-baseline.json"

    # Ensure analytics directory exists for baseline tests
    mkdir -p "$ANALYTICS_DIR"
}