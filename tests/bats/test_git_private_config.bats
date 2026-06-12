#!/usr/bin/env bats

# Test suite for git private configuration functionality
# Destructive use-private-git tests live in test_gcl_integration_ci.bats (CI only)

load setup_suite

setup() {
    # Create temporary test directory
    export TEST_DIR=$(mktemp -d)
    export ORIGINAL_DIR=$(pwd)

    # Create temporary dotfiles structure
    export TEMP_DOTFILES="$TEST_DIR/dotfiles"
    mkdir -p "$TEMP_DOTFILES/git"
    mkdir -p "$TEMP_DOTFILES/bin"

    # Copy scripts to test environment
    # Ensure DOTFILES_DIR is set
    ensure_dotfiles_dir
    cp "$DOTFILES_DIR/bin/gcl" "$TEMP_DOTFILES/bin/"
    cp "$DOTFILES_DIR/bin/use-private-git" "$TEMP_DOTFILES/bin/"

    # Create test base config
    cat > "$TEMP_DOTFILES/git/.gitconfig.private.base" << 'EOF'
[user]
	name = Test User
	email = test@example.com
[core]
	editor = vim
[alias]
	x = !git-x
EOF

    # Update PATH to use test scripts
    export PATH="$TEMP_DOTFILES/bin:$PATH"

    # Update HOME references in scripts to use test directory
    sed -i.bak "s|$HOME/repos/dotfiles|$TEMP_DOTFILES|g" "$TEMP_DOTFILES/bin/use-private-git"

    cd "$TEST_DIR"
}

teardown() {
    cd "$ORIGINAL_DIR"
    rm -rf "$TEST_DIR"
}

@test "base config file exists and is valid" {
    [ -f "$TEMP_DOTFILES/git/.gitconfig.private.base" ]
    run git config -f "$TEMP_DOTFILES/git/.gitconfig.private.base" --list
    [ "$status" -eq 0 ]
}

@test "base config does not contain repo-specific settings" {
    # Check that problematic sections are not present
    run grep -E "\[init\]|\[remote|\[submodule" "$TEMP_DOTFILES/git/.gitconfig.private.base"
    [ "$status" -ne 0 ]
}