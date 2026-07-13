#!/usr/bin/env bash

# Bats test suite setup
# This file runs once before all tests in the suite

# Locate the repository root without hardcoding any machine-specific path.
# The relative path from this file is the primary strategy; CI and cwd
# fallbacks follow.
find_dotfiles_dir() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    local search_paths=(
        "$(cd "$script_dir/../.." && pwd)"      # Relative to this file (primary)
        "${BATS_TEST_DIRNAME:+$(cd "$BATS_TEST_DIRNAME/../.." 2>/dev/null && pwd)}"
        "${GITHUB_WORKSPACE:-}"                  # CI environment
        "$(pwd)"                                 # Current directory
    )

    local path
    for path in "${search_paths[@]}"; do
        if [[ -n "$path" && -f "$path/Makefile" && -d "$path/bin" && -f "$path/bin/gcl" ]]; then
            echo "$path"
            return 0
        fi
    done

    return 1
}

setup_suite() {
    export DOTFILES_DIR=""
    if ! DOTFILES_DIR="$(find_dotfiles_dir)"; then
        echo "ERROR: Could not find repository root with required files (Makefile, bin/gcl)" >&2
        exit 1
    fi
    export DOTFILES_DIR

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

    # Analytics dir is read-only for tests (plugin performance data, if any).
    # Tests must never create or write to this directory.
    export ANALYTICS_DIR="${HOME:-/tmp}/.config/dotfiles"
}

# Helper function to ensure DOTFILES_DIR is set properly for any test
ensure_dotfiles_dir() {
    if [[ -z "${DOTFILES_DIR:-}" ]]; then
        if ! DOTFILES_DIR="$(find_dotfiles_dir)"; then
            echo "ERROR: Could not find repository root with required files (Makefile, bin/gcl)" >&2
            return 1
        fi
        export DOTFILES_DIR
    fi
    return 0
}
