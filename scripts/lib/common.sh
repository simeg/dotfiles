#!/usr/bin/env bash

# Common utility functions and constants used across dotfiles scripts
# This file consolidates duplicated code from multiple scripts

# Prevent re-sourcing
if [[ -n "${_COMMON_SOURCED:-}" ]]; then
    return 0
fi
_COMMON_SOURCED=1

# Color definitions (previously duplicated in 15+ scripts)
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
# shellcheck disable=SC2034  # Used in other scripts
readonly CYAN='\033[0;36m'
# readonly WHITE='\033[1;37m'  # Unused - keeping for potential future use
# readonly BOLD='\033[1m'  # Unused - keeping for potential future use
readonly DIM='\033[2m'
readonly NC='\033[0m'

# Logging functions (previously duplicated in 15+ scripts)
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${DIM}[DEBUG]${NC} $1" >&2
    fi
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1" >&2
}

# Common utility functions
check_command_exists() {
    command -v "$1" &>/dev/null
}

get_timestamp() {
    date +%s
}

get_formatted_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Platform detection
is_macos() {
    [[ "$OSTYPE" == "darwin"* ]]
}

is_linux() {
    [[ "$OSTYPE" == "linux-gnu"* ]]
}

# Common path functions
get_dotfiles_root() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    echo "$script_dir"
}

get_config_dir() {
    echo "${HOME}/.config"
}

# File operations
backup_file() {
    local file="$1"
    local backup_dir="${2:-${HOME}/.dotfiles-backup}"

    if [[ -f "$file" ]]; then
        mkdir -p "$backup_dir"
        cp "$file" "$backup_dir/$(basename "$file").$(date +%s)"
        log_info "Backed up $file"
    fi
}

# Progress indicators
show_spinner() {
    local pid=$1
    local message="$2"
    local spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0

    echo -n "$message "
    while kill -0 "$pid" 2>/dev/null; do
        printf "\b%s" "${spinner:$i:1}"
        i=$(( (i + 1) % ${#spinner} ))
        sleep 0.1
    done
    printf "\b✓\n"
}

# Run a command with a spinner
run_with_spinner() {
    local message="$1"
    shift

    # Run the command in background
    "$@" &
    local pid=$!

    # Show spinner while command runs
    show_spinner $pid "$message"

    # Wait for command to complete and return its exit code
    wait $pid
    return $?
}

# String utilities
trim() {
    local str="$1"
    echo "$str" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

to_lowercase() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Confirmation prompts
confirm() {
    local prompt="${1:-Are you sure?}"
    local default="${2:-n}"

    # In CI environments, use the default without prompting
    if [[ "$DOTFILES_CI" == "true" ]] || [[ -n "$CI" ]] || [[ -n "$GITHUB_ACTIONS" ]]; then
        log_info "CI environment detected, using default response: $default"
        case "$(to_lowercase "$default")" in
            y|yes) return 0 ;;
            *) return 1 ;;
        esac
    fi

    while true; do
        if [[ "$default" == "y" ]]; then
            read -p "$prompt [Y/n]: " -r response
            response="${response:-y}"
        else
            read -p "$prompt [y/N]: " -r response
            response="${response:-n}"
        fi

        case "$(to_lowercase "$response")" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}

# Check if running in CI environment
is_ci() {
    [[ "${CI:-false}" == "true" ]] || [[ -n "${GITHUB_ACTIONS:-}" ]]
}

# Version comparison
version_gte() {
    local version1="$1"
    local version2="$2"
    printf '%s\n%s\n' "$version1" "$version2" | sort -V -C
}
