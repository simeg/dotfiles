#!/usr/bin/env bats

# Unit tests for git configuration functionality
# These tests are safe to run locally and don't create repos or modify filesystem

load setup_suite

@test "use-private-git script exists and is executable" {
    ensure_dotfiles_dir
    [ -f "$DOTFILES_DIR/bin/use-private-git" ]
    [ -x "$DOTFILES_DIR/bin/use-private-git" ]
}

@test "gcl script exists and is executable" {
    ensure_dotfiles_dir
    [ -f "$DOTFILES_DIR/bin/gcl" ]
    [ -x "$DOTFILES_DIR/bin/gcl" ]
}

@test "git private base config exists and is valid" {
    ensure_dotfiles_dir
    [ -f "$DOTFILES_DIR/git/.gitconfig.private.base" ]

    # Test that it's valid git config syntax
    run git config -f "$DOTFILES_DIR/git/.gitconfig.private.base" --list
    [ "$status" -eq 0 ]
}

@test "base config contains expected user settings" {
    ensure_dotfiles_dir
    run git config -f "$DOTFILES_DIR/git/.gitconfig.private.base" user.name
    [ "$status" -eq 0 ]
    [ -n "$output" ]

    run git config -f "$DOTFILES_DIR/git/.gitconfig.private.base" user.email
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "base config contains delta settings" {
    ensure_dotfiles_dir
    run git config -f "$DOTFILES_DIR/git/.gitconfig.private.base" delta.features
    [ "$status" -eq 0 ]
    [ "$output" = "diff-so-fancy" ]
}

@test "base config does NOT contain repo-specific sections" {
    ensure_dotfiles_dir
    # Should not contain init.defaultBranch
    run git config -f "$DOTFILES_DIR/git/.gitconfig.private.base" init.defaultBranch
    [ "$status" -ne 0 ]

    # Should not contain submodule sections
    run grep -q "\[submodule" "$DOTFILES_DIR/git/.gitconfig.private.base"
    [ "$status" -ne 0 ]

    # Should not contain remote sections
    run grep -q "\[remote" "$DOTFILES_DIR/git/.gitconfig.private.base"
    [ "$status" -ne 0 ]
}

@test "use-private-git shows help with --help flag" {
    run "$DOTFILES_DIR/bin/use-private-git" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"--force"* ]]
    [[ "$output" == *"--remove"* ]]
}

@test "gcl shows help with --help flag" {
    run "$DOTFILES_DIR/bin/gcl" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"--shallow"* ]]
    [[ "$output" == *"--branch"* ]]
}

@test "use-private-git validates required base config exists" {
    ensure_dotfiles_dir
    # Test that the script looks for the base config in the right place
    # This is a read-only test that doesn't actually modify anything
    run grep -q "PRIVATE_GITCONFIG_BASE.*\.gitconfig\.private\.base" "$DOTFILES_DIR/bin/use-private-git"
    [ "$status" -eq 0 ]
}

@test "gcl validates repository URL format" {
    ensure_dotfiles_dir
    # Should reject invalid URLs
    run "$DOTFILES_DIR/bin/gcl" "not-a-url"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Invalid repository URL format"* ]]

    run "$DOTFILES_DIR/bin/gcl" "just-text"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Invalid repository URL format"* ]]
}

@test "gcl protocol conversion works correctly" {
    ensure_dotfiles_dir
    # Test HTTPS to SSH conversion (this just tests the logic, doesn't clone)
    temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # This should show the protocol conversion message but fail to clone (expected)
    run "$DOTFILES_DIR/bin/gcl" --ssh "https://github.com/user/repo.git" test-repo 2>&1 || true
    [[ "$output" == *"Using ssh protocol"* ]]

    cd - >/dev/null
    rm -rf "$temp_dir"
}

@test "old git private config was properly backed up" {
    ensure_dotfiles_dir
    # Check that the old config was moved to .old (if backup exists)
    if [ -f "$DOTFILES_DIR/git/.gitconfig.private.old" ]; then
        # Verify it contains the problematic sections we removed
        run grep -q "\[init\]" "$DOTFILES_DIR/git/.gitconfig.private.old"
        [ "$status" -eq 0 ]

        run grep -q "\[submodule" "$DOTFILES_DIR/git/.gitconfig.private.old"
        [ "$status" -eq 0 ]

        run grep -q "\[remote" "$DOTFILES_DIR/git/.gitconfig.private.old"
        [ "$status" -eq 0 ]
    else
        skip "No backup file found - migration already complete"
    fi
}
