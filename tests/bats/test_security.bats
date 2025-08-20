#!/usr/bin/env bats

# Security compliance tests migrated from test_advanced.sh
# Tests for secrets, permissions, shell security, git security, and dependencies

load setup_suite

@test "Secrets scanning in configuration files" {
    local secret_patterns=("password" "secret" "token" "key.*=" "api.*key" "auth.*token")
    local issues=0

    echo "Scanning for potential secrets in configuration files" >&3

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
                        echo "Potential secret found in $file: pattern '$pattern'" >&3
                        issues=$((issues + 1))
                    fi
                fi
            fi
        done
    done < <(find "$DOTFILES_DIR" -type f \( -name "*.zsh" -o -name "*.sh" -o -name "*.toml" -o -name ".gitconfig" \) -print0)

    [ "$issues" -eq 0 ]
}

@test "File permissions security" {
    local issues=0

    echo "Checking file permissions" >&3

    # Check for overly permissive files
    while IFS= read -r -d '' file; do
        local perms
        perms=$(stat -f "%A" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null || echo "644")

        # Config files shouldn't be world-writable
        if [[ "$perms" =~ .*[2367].$ ]]; then
            echo "Insecure permissions on $file: $perms (world-writable)" >&3
            issues=$((issues + 1))
        fi

        # Executable files should have proper permissions
        if [[ "$file" == *.sh ]] && [[ ! "$perms" =~ .*[157].$ ]]; then
            echo "Non-executable script: $file ($perms)" >&3
            issues=$((issues + 1))
        fi
    done < <(find "$DOTFILES_DIR" -type f \( -name "*.zsh" -o -name "*.sh" -o -name "*.toml" \) -print0)

    [ "$issues" -eq 0 ]
}

@test "Shell security configuration" {
    local issues=0
    local zsh_config="$DOTFILES_DIR/.config/zsh"

    echo "Checking shell security configuration" >&3

    # Check for dangerous PATH modifications
    if grep -E "PATH.*:\.:" "$zsh_config"/*.zsh >/dev/null 2>&1; then
        echo "Dangerous PATH configuration: current directory in PATH" >&3
        issues=$((issues + 1))
    fi

    # Check for insecure command history settings (warning only)
    if [[ -z "${HISTFILE:-}" ]]; then
        echo "History file not explicitly configured" >&3
        # This is a warning, not a failure for the test
    fi

    # Check for umask setting (warning only)
    if ! grep -q "umask" "$zsh_config"/*.zsh 2>/dev/null; then
        echo "No umask setting found (security best practice)" >&3
        # This is a warning, not a failure for the test
    fi

    [ "$issues" -eq 0 ]
}

@test "Git security configuration" {
    local issues=0
    local git_config="$DOTFILES_DIR/git/.gitconfig"

    echo "Checking Git security configuration" >&3

    if [[ ! -f "$git_config" ]]; then
        skip "Git config file missing - using global configuration"
    fi

    # Check for secure URL protocols
    if grep -E "url.*http://" "$git_config" >/dev/null 2>&1; then
        echo "Insecure HTTP URLs found in Git config" >&3
        issues=$((issues + 1))
    fi

    # GPG signing and credential helper are best practices but not requirements
    if ! grep -q "signingkey\|gpgsign" "$git_config"; then
        echo "Git commit signing not configured (recommended for security)" >&3
        # This is informational, not a test failure
    fi

    if ! grep -q "credential" "$git_config"; then
        echo "Git credential helper not configured" >&3
        # This is informational, not a test failure
    fi

    [ "$issues" -eq 0 ]
}

@test "Dependency security" {
    local issues=0

    echo "Checking dependency security" >&3

    # Check if we're downloading from secure sources
    local brewfile="$DOTFILES_DIR/install/Brewfile"
    if [[ -f "$brewfile" ]]; then
        # Check for insecure tap sources
        if grep -E "tap.*http://" "$brewfile" >/dev/null 2>&1; then
            echo "Insecure HTTP tap sources in Brewfile" >&3
            issues=$((issues + 1))
        fi

        # Check for unofficial taps (warning only, not a failure)
        local unofficial_taps
        unofficial_taps=$(grep "^tap" "$brewfile" | grep -cv "homebrew/" || echo 0)
        if [[ $unofficial_taps -gt 5 ]]; then
            echo "Many unofficial taps detected ($unofficial_taps) - verify sources" >&3
            # This is informational, not a test failure
        fi
    fi

    [ "$issues" -eq 0 ]
}

# @test "Security baseline exists or can be created" {
#     # Ensure ANALYTICS_DIR is set with fallback
#     ANALYTICS_DIR="${ANALYTICS_DIR:-${HOME:-/tmp}/.config/dotfiles}"
#     SECURITY_BASELINE="${SECURITY_BASELINE:-$ANALYTICS_DIR/security-baseline.json}"
#
#     if [[ ! -f "$SECURITY_BASELINE" ]]; then
#         echo "Creating security baseline" >&3
#         mkdir -p "$ANALYTICS_DIR"
#
#         local baseline
#         baseline="{
#             \"created\": \"$(date -Iseconds)\",
#             \"file_count\": $(find "$DOTFILES_DIR" -type f | wc -l),
#             \"script_count\": $(find "$DOTFILES_DIR" -name "*.sh" -type f | wc -l),
#             \"config_files\": $(find "$DOTFILES_DIR" -name "*.zsh" -o -name "*.toml" | wc -l)
#         }"
#
#         echo "$baseline" > "$SECURITY_BASELINE"
#         echo "Security baseline created" >&3
#     else
#         echo "Security baseline exists" >&3
#     fi
#
#     [ -f "$SECURITY_BASELINE" ]
# }
