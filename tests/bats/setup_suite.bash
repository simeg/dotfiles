#!/usr/bin/env bash

# Bats test suite setup
# This file runs once before all tests in the suite

setup_suite() {
    # Load shared libraries
    # Determine repository root directory reliably across different environments
    local search_paths=(
        "${GITHUB_WORKSPACE}"                                 # CI environment (act sets this)
        "/Users/segersand/repos/dotfiles"                     # Act container path
        "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)" # Standard relative path
        "$(pwd)"                                               # Current directory
    )

    export DOTFILES_DIR=""
    for path in "${search_paths[@]}"; do
        if [[ -n "$path" && -f "$path/Makefile" && -d "$path/bin" && -f "$path/bin/gcl" ]]; then
            export DOTFILES_DIR="$path"
            break
        fi
    done

    # If still not found, fail early with helpful error
    if [[ -z "$DOTFILES_DIR" ]]; then
        echo "ERROR: Could not find repository root with required files (Makefile, bin/gcl)" >&2
        echo "Searched paths: ${search_paths[*]}" >&2
        exit 1
    fi

    export SCRIPT_DIR="$DOTFILES_DIR/scripts"

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
    export ANALYTICS_DIR="${HOME:-/tmp}/.config/dotfiles"
    export PERF_BASELINE="$ANALYTICS_DIR/perf-baseline.json"
    export SECURITY_BASELINE="$ANALYTICS_DIR/security-baseline.json"

    # Ensure analytics directory exists for baseline tests
    mkdir -p "$ANALYTICS_DIR"
}

# Helper function to ensure DOTFILES_DIR is set properly for any test
ensure_dotfiles_dir() {
    if [[ -z "$DOTFILES_DIR" ]]; then
        local search_paths=(
            "${GITHUB_WORKSPACE}"                                 # CI environment (act sets this)
            "/Users/segersand/repos/dotfiles"                     # Act container path
            "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)" # Standard relative path
            "$(pwd)"                                               # Current directory
        )

        for path in "${search_paths[@]}"; do
            if [[ -n "$path" && -f "$path/Makefile" && -d "$path/bin" && -f "$path/bin/gcl" ]]; then
                export DOTFILES_DIR="$path"
                break
            fi
        done

        if [[ -z "$DOTFILES_DIR" ]]; then
            echo "ERROR: Could not find repository root with required files (Makefile, bin/gcl)" >&2
            return 1
        fi
    fi
    return 0
}