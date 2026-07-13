#!/usr/bin/env bats

# Security compliance tests
# Tests for secrets, permissions, shell security, git security, and dependencies

load setup_suite

# Scan a file for secret-looking VALUES (not just secret-ish words).
# Prints offending lines; returns 0 if any hit was found.
scan_file_for_secrets() {
    local file="$1"

    # Patterns that match actual credential material:
    # - password/passwd assigned a literal value (not a variable reference)
    # - api key / secret / token assigned a long literal value
    local ci_patterns=(
        '(password|passwd)[[:space:]]*[=:][[:space:]]*["'\'']?[A-Za-z0-9!@#%^&*_+-]{6,}'
        '(api[_-]?key|client[_-]?secret|access[_-]?token|auth[_-]?token)[[:space:]]*[=:][[:space:]]*["'\'']?[A-Za-z0-9/+_-]{16,}'
    )
    # Case-sensitive well-known token formats:
    # AWS access key IDs, GitHub PATs, Slack tokens, private key blocks
    local cs_patterns=(
        'AKIA[0-9A-Z]{16}'
        'ghp_[A-Za-z0-9]{36}'
        'github_pat_[A-Za-z0-9_]{22,}'
        'xox[baprs]-[A-Za-z0-9-]{10,}'
        '-----BEGIN[[:space:]].*PRIVATE[[:space:]]KEY-----'
    )

    # Line-level exclusions: comments (#, ;, //) and values that are
    # shell variable references rather than literals.
    filter_safe_lines() {
        grep -vE '^[0-9]+:[[:space:]]*(#|;|//)' \
            | grep -vE '[=:][[:space:]]*["'\'']?\$' || true
    }

    local pattern hits found=1
    for pattern in "${ci_patterns[@]}"; do
        hits=$(grep -inE "$pattern" "$file" 2>/dev/null | filter_safe_lines)
        if [[ -n "$hits" ]]; then
            echo "$file (pattern: $pattern):"
            echo "$hits"
            found=0
        fi
    done
    for pattern in "${cs_patterns[@]}"; do
        hits=$(grep -nE "$pattern" "$file" 2>/dev/null | filter_safe_lines)
        if [[ -n "$hits" ]]; then
            echo "$file (pattern: $pattern):"
            echo "$hits"
            found=0
        fi
    done

    return "$found"
}

@test "Secrets scanning in configuration files" {
    local issues=0

    echo "Scanning for potential secrets in configuration files" >&3

    while IFS= read -r -d '' file; do
        local report
        if report=$(scan_file_for_secrets "$file"); then
            echo "Potential secret found in $report" >&3
            issues=$((issues + 1))
        fi
    done < <(find "$DOTFILES_DIR" -type f \
        \( -name "*.zsh" -o -name "*.sh" -o -name "*.toml" -o -name ".gitconfig*" \) \
        -not -path "*/.git/*" -print0)

    [ "$issues" -eq 0 ]
}

@test "Secrets scanner catches a planted secret" {
    # Self-test: the scanner must be able to fail. Plant a fake credential
    # in a temp file and verify the scanner flags it.
    local scratch="$BATS_TEST_TMPDIR/planted.zsh"
    cat > "$scratch" << 'EOF'
export DB_PASSWORD="hunter2hunter2"
aws_key=AKIAIOSFODNN7EXAMPLE
EOF

    run scan_file_for_secrets "$scratch"
    [ "$status" -eq 0 ]
    [[ "$output" == *"AKIA"* ]]

    # And a clean file must NOT be flagged
    local clean="$BATS_TEST_TMPDIR/clean.zsh"
    cat > "$clean" << 'EOF'
# password handling is documented elsewhere
export GITHUB_TOKEN="$SOME_VAR"
EOF
    run scan_file_for_secrets "$clean"
    [ "$status" -ne 0 ]
}

@test "File permissions security" {
    local issues=0

    echo "Checking file permissions" >&3

    while IFS= read -r -d '' file; do
        local perms
        perms=$(stat -f "%A" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null || echo "644")

        # Config files shouldn't be world-writable (last octal digit has the
        # write bit set: 2, 3, 6, or 7)
        if [[ "$perms" =~ [2367]$ ]]; then
            echo "Insecure permissions on $file: $perms (world-writable)" >&3
            issues=$((issues + 1))
        fi

        # Shell scripts should be executable by their owner
        if [[ "$file" == *.sh ]] && [[ ! -x "$file" ]]; then
            echo "Non-executable script: $file ($perms)" >&3
            issues=$((issues + 1))
        fi
    done < <(find "$DOTFILES_DIR" -type f \( -name "*.zsh" -o -name "*.sh" -o -name "*.toml" \) \
        -not -path "*/.git/*" -print0)

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

    [ "$issues" -eq 0 ]
}

@test "Git security configuration" {
    local issues=0
    local git_config="$DOTFILES_DIR/git/.gitconfig"

    echo "Checking Git security configuration" >&3

    if [[ ! -f "$git_config" ]]; then
        skip "Git config file missing - using global configuration"
    fi

    # Check for insecure URL protocols
    if grep -E "url.*http://" "$git_config" >/dev/null 2>&1; then
        echo "Insecure HTTP URLs found in Git config" >&3
        issues=$((issues + 1))
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
    fi

    [ "$issues" -eq 0 ]
}
