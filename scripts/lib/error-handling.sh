#!/usr/bin/env bash

# Standardized error handling for dotfiles scripts
# This file provides consistent error handling patterns across all scripts

# Source common utilities (only if not already sourced)
if [[ -z "${_COMMON_SOURCED:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # shellcheck source=scripts/lib/common.sh
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/common.sh"
fi

# Global error handling variables
ERROR_OCCURRED=false
ROLLBACK_COMMANDS=()
CLEANUP_COMMANDS=()
ERROR_LOG_FILE=""

# Initialize error handling for a script
setup_error_handling() {
    local script_name="${1:-$(basename "$0")}"
    local enable_rollback="${2:-true}"
    local log_errors="${3:-false}"
    
    # Set bash error handling options
    set -eE  # Exit on error, inherit ERR trap
    
    # Set up error log if requested
    if [[ "$log_errors" == "true" ]]; then
        ERROR_LOG_FILE="/tmp/dotfiles-error-$(date +%s).log"
        touch "$ERROR_LOG_FILE"
        log_debug "Error logging enabled: $ERROR_LOG_FILE"
    fi
    
    # Set up ERR trap
    if [[ "$enable_rollback" == "true" ]]; then
        trap 'handle_error_with_rollback $? $LINENO $BASH_COMMAND' ERR
    else
        trap 'handle_error_simple $? $LINENO $BASH_COMMAND' ERR
    fi
    
    # Set up EXIT trap for cleanup
    trap 'cleanup_on_exit' EXIT
    
    log_debug "Error handling initialized for $script_name"
}

# Simple error handler without rollback
handle_error_simple() {
    local exit_code="$1"
    local line_number="$2"
    local command="$3"
    
    ERROR_OCCURRED=true
    
    log_error "Script failed with exit code $exit_code"
    log_error "Failed at line $line_number: $command"
    
    # Log to file if enabled
    if [[ -n "$ERROR_LOG_FILE" ]]; then
        {
            echo "$(get_formatted_timestamp): Error in $(basename "$0")"
            echo "  Exit code: $exit_code"
            echo "  Line: $line_number"
            echo "  Command: $command"
            echo "  Working directory: $(pwd)"
            echo "---"
        } >> "$ERROR_LOG_FILE"
    fi
    
    # Call custom cleanup function if it exists
    if declare -f cleanup_on_error >/dev/null 2>&1; then
        log_debug "Calling custom cleanup_on_error function"
        cleanup_on_error
    fi
    
    exit "$exit_code"
}

# Enhanced error handler with rollback capability
handle_error_with_rollback() {
    local exit_code="$1"
    local line_number="$2"
    local command="$3"
    
    ERROR_OCCURRED=true
    
    log_error "Script failed with exit code $exit_code"
    log_error "Failed at line $line_number: $command"
    
    # Log to file if enabled
    if [[ -n "$ERROR_LOG_FILE" ]]; then
        {
            echo "$(get_formatted_timestamp): Error in $(basename "$0")"
            echo "  Exit code: $exit_code"
            echo "  Line: $line_number"
            echo "  Command: $command"
            echo "  Working directory: $(pwd)"
            echo "  Rollback commands available: ${#ROLLBACK_COMMANDS[@]}"
            echo "---"
        } >> "$ERROR_LOG_FILE"
    fi
    
    # Execute rollback if commands are available and not in CI
    if [[ ${#ROLLBACK_COMMANDS[@]} -gt 0 ]] && ! is_ci; then
        if confirm "Script failed. Do you want to rollback changes?" "y"; then
            execute_rollback
            log_info "Rollback completed due to script failure"
        else
            log_warning "Script failed but rollback was skipped"
        fi
    elif [[ ${#ROLLBACK_COMMANDS[@]} -gt 0 ]] && is_ci; then
        log_info "Executing automatic rollback in CI environment"
        execute_rollback
    else
        log_warning "Script failed with no rollback actions available"
    fi
    
    # Call custom cleanup function if it exists
    if declare -f cleanup_on_error >/dev/null 2>&1; then
        log_debug "Calling custom cleanup_on_error function"
        cleanup_on_error
    fi
    
    exit "$exit_code"
}

# Add command to rollback list
add_rollback() {
    local command="$1"
    local description="${2:-Rollback command}"
    
    ROLLBACK_COMMANDS+=("$command")
    log_debug "Added rollback: $description"
}

# Add command to cleanup list (always executed on exit)
add_cleanup() {
    local command="$1"
    local description="${2:-Cleanup command}"
    
    CLEANUP_COMMANDS+=("$command")
    log_debug "Added cleanup: $description"
}

# Execute rollback commands in reverse order
execute_rollback() {
    if [[ ${#ROLLBACK_COMMANDS[@]} -eq 0 ]]; then
        log_debug "No rollback commands to execute"
        return 0
    fi
    
    log_warning "Executing rollback commands..."
    
    # Execute in reverse order (LIFO)
    for (( i=${#ROLLBACK_COMMANDS[@]}-1 ; i>=0 ; i-- )); do
        local cmd="${ROLLBACK_COMMANDS[i]}"
        log_info "Rolling back: $cmd"
        
        if eval "$cmd"; then
            log_debug "Rollback command succeeded: $cmd"
        else
            log_warning "Rollback command failed: $cmd"
        fi
    done
    
    log_success "Rollback execution completed"
}

# Execute cleanup commands (called on EXIT)
cleanup_on_exit() {
    local exit_code=$?
    
    # Execute cleanup commands
    if [[ ${#CLEANUP_COMMANDS[@]} -gt 0 ]]; then
        log_debug "Executing cleanup commands..."
        
        for cmd in "${CLEANUP_COMMANDS[@]}"; do
            log_debug "Cleanup: $cmd"
            eval "$cmd" || log_warning "Cleanup command failed: $cmd"
        done
    fi
    
    # Clean up error log if it exists and script succeeded
    if [[ -n "$ERROR_LOG_FILE" ]] && [[ "$ERROR_OCCURRED" == "false" ]] && [[ -f "$ERROR_LOG_FILE" ]]; then
        rm -f "$ERROR_LOG_FILE"
        log_debug "Removed error log file (script succeeded)"
    fi
    
    # Don't change exit code
    exit $exit_code
}

# Safe command execution with optional rollback
safe_execute() {
    local command="$1"
    local rollback_command="${2:-}"
    local description="${3:-Command}"
    
    log_debug "Executing: $description"
    
    if eval "$command"; then
        # Add rollback command if provided and command succeeded
        if [[ -n "$rollback_command" ]]; then
            add_rollback "$rollback_command" "Rollback: $description"
        fi
        return 0
    else
        local exit_code=$?
        log_error "$description failed with exit code $exit_code"
        return $exit_code
    fi
}

# Safe file operations with backup
safe_backup_and_move() {
    local source="$1"
    local destination="$2"
    local backup_dir="${3:-${HOME}/.dotfiles-backup}"
    
    if [[ ! -f "$source" ]]; then
        log_error "Source file does not exist: $source"
        return 1
    fi
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    # Backup existing destination if it exists
    if [[ -f "$destination" ]]; then
        local backup_file
        backup_file="$backup_dir/$(basename "$destination").$(date +%s)"
        cp "$destination" "$backup_file"
        add_rollback "cp '$backup_file' '$destination'" "Restore $(basename "$destination")"
        log_debug "Backed up $destination to $backup_file"
    fi
    
    # Move/copy file
    if cp "$source" "$destination"; then
        add_rollback "rm -f '$destination'" "Remove $(basename "$destination")"
        log_success "Moved $source to $destination"
        return 0
    else
        log_error "Failed to move $source to $destination"
        return 1
    fi
}

# Safe symlink creation with rollback
safe_symlink() {
    local target="$1"
    local link_path="$2"
    local backup_dir="${3:-${HOME}/.dotfiles-backup}"
    
    if [[ ! -e "$target" ]]; then
        log_error "Symlink target does not exist: $target"
        return 1
    fi
    
    # Backup existing file/link if it exists
    if [[ -e "$link_path" ]] || [[ -L "$link_path" ]]; then
        mkdir -p "$backup_dir"
        local backup_file
        backup_file="$backup_dir/$(basename "$link_path").$(date +%s)"
        
        if [[ -L "$link_path" ]]; then
            # It's a symlink, backup the link itself
            cp -P "$link_path" "$backup_file.link"
            add_rollback "mv '$backup_file.link' '$link_path'" "Restore symlink $(basename "$link_path")"
        else
            # It's a regular file/directory
            cp -r "$link_path" "$backup_file"
            add_rollback "rm -rf '$link_path' && mv '$backup_file' '$link_path'" "Restore $(basename "$link_path")"
        fi
        
        rm -rf "$link_path"
    fi
    
    # Create symlink
    if ln -sf "$target" "$link_path"; then
        add_rollback "rm -f '$link_path'" "Remove symlink $(basename "$link_path")"
        log_success "Created symlink: $link_path → $target"
        return 0
    else
        log_error "Failed to create symlink: $link_path → $target"
        return 1
    fi
}

# Disable error handling (useful for specific sections)
disable_error_handling() {
    set +e
    trap - ERR
    log_debug "Error handling disabled"
}

# Re-enable error handling
enable_error_handling() {
    set -e
    trap 'handle_error_with_rollback $? $LINENO $BASH_COMMAND' ERR
    log_debug "Error handling re-enabled"
}

# Check if error handling is active
is_error_handling_active() {
    [[ "$-" == *e* ]]
}

# Get error status
get_error_status() {
    if [[ "$ERROR_OCCURRED" == "true" ]]; then
        echo "error"
    else
        echo "success"
    fi
}

# Print error summary
print_error_summary() {
    if [[ "$ERROR_OCCURRED" == "true" ]]; then
        log_error "Script completed with errors"
        if [[ -n "$ERROR_LOG_FILE" ]] && [[ -f "$ERROR_LOG_FILE" ]]; then
            log_info "Error details logged to: $ERROR_LOG_FILE"
        fi
        return 1
    else
        log_success "Script completed successfully"
        return 0
    fi
}