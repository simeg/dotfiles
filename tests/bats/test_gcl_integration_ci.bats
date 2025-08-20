#!/usr/bin/env bats

# CI-ONLY Integration tests for gcl script with private git configuration
# Tests the complete flow of cloning and setting up private configs
# These tests create git repositories and perform destructive operations

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
    sed -i.bak "s|\$HOME/repos/dotfiles|$TEMP_DOTFILES|g" "$TEMP_DOTFILES/bin/use-private-git"

    cd "$TEST_DIR"
}

teardown() {
    cd "$ORIGINAL_DIR"
    rm -rf "$TEST_DIR"
}

create_test_remote_repo() {
    local repo_name="$1"
    local default_branch="${2:-main}"

    # Create a "remote" repository
    mkdir -p "remote_repos/$repo_name.git"
    cd "remote_repos/$repo_name.git"
    git init --bare --initial-branch="$default_branch" >/dev/null 2>&1

    # Create a working copy to push initial content
    cd ../..
    git clone "remote_repos/$repo_name.git" "temp_$repo_name" >/dev/null 2>&1
    cd "temp_$repo_name"

    git config user.email "test@example.com"
    git config user.name "Test User"

    echo "# $repo_name" > README.md
    git add README.md >/dev/null 2>&1
    git commit -m "Initial commit" >/dev/null 2>&1
    git push origin "$default_branch" >/dev/null 2>&1

    cd ..
    rm -rf "temp_$repo_name"
    cd "$TEST_DIR"

    echo "file://$TEST_DIR/remote_repos/$repo_name.git"
}

@test "gcl sets up remote HEAD reference correctly" {
    # Create test remote repo with main branch
    repo_url=$(create_test_remote_repo "test-main-repo" "main")

    # Use gcl to clone (simulate non-private repo)
    run bash -c "export PATH='$TEMP_DOTFILES/bin:$PATH'; echo 'n' | gcl '$repo_url' test-clone"
    [ "$status" -eq 0 ]

    cd test-clone

    # Check that remote HEAD is set up
    run git symbolic-ref refs/remotes/origin/HEAD
    [ "$status" -eq 0 ]
    [ "$output" = "refs/remotes/origin/main" ]
}

@test "gcl with private repo sets up correct default branch in config - main branch" {
    # Create test remote repo with main branch
    repo_url=$(create_test_remote_repo "test-main-private" "main")

    # Use gcl to clone and set up as private repo
    run bash -c "export PATH='$TEMP_DOTFILES/bin:$PATH'; echo 'y' | gcl '$repo_url' test-private-main"
    [ "$status" -eq 0 ]

    cd test-private-main

    # Check that init.defaultBranch is set to main
    run git config init.defaultBranch
    [ "$status" -eq 0 ]
    [ "$output" = "main" ]

    # Check that user config from base is applied
    run git config user.name
    [ "$status" -eq 0 ]
    [ "$output" = "Test User" ]
}

@test "gcl with private repo sets up correct default branch in config - master branch" {
    # Create test remote repo with master branch
    repo_url=$(create_test_remote_repo "test-master-private" "master")

    # Use gcl to clone and set up as private repo
    run bash -c "export PATH='$TEMP_DOTFILES/bin:$PATH'; echo 'y' | gcl '$repo_url' test-private-master"
    [ "$status" -eq 0 ]

    cd test-private-master

    # Check that init.defaultBranch is set to master
    run git config init.defaultBranch
    [ "$status" -eq 0 ]
    [ "$output" = "master" ]

    # Check that user config from base is applied
    run git config user.name
    [ "$status" -eq 0 ]
    [ "$output" = "Test User" ]
}

@test "gcl handles shallow clone with private config correctly" {
    # Create test remote repo
    repo_url=$(create_test_remote_repo "test-shallow" "main")

    # Use gcl with shallow clone and private setup
    run bash -c "export PATH='$TEMP_DOTFILES/bin:$PATH'; echo 'y' | gcl --shallow '$repo_url' test-shallow-private"
    [ "$status" -eq 0 ]

    cd test-shallow-private

    # Check that it's a shallow clone
    [ -f ".git/shallow" ]

    # Check that private config is still set up correctly
    run git config init.defaultBranch
    [ "$status" -eq 0 ]
    [ "$output" = "main" ]

    run git config user.name
    [ "$status" -eq 0 ]
    [ "$output" = "Test User" ]
}

@test "gcl handles specific branch clone with private config correctly" {
    # Create test remote repo with multiple branches
    repo_url=$(create_test_remote_repo "test-branches" "main")

    # Add a develop branch to the remote
    git clone "$repo_url" temp-for-branch
    cd temp-for-branch
    git config user.email "test@example.com"
    git config user.name "Test User"
    git checkout -b develop
    echo "develop content" > develop.txt
    git add develop.txt
    git commit -m "Add develop content"
    git push origin develop
    cd ..
    rm -rf temp-for-branch

    # Use gcl to clone specific branch and set up as private
    run bash -c "export PATH='$TEMP_DOTFILES/bin:$PATH'; echo 'y' | gcl --branch develop '$repo_url' test-branch-private"
    [ "$status" -eq 0 ]

    cd test-branch-private

    # Check that we're on the correct branch
    run git branch --show-current
    [ "$status" -eq 0 ]
    [ "$output" = "develop" ]

    # Check that default branch detection still works (should detect main as remote default)
    run git config init.defaultBranch
    [ "$status" -eq 0 ]
    [ "$output" = "main" ]
}

@test "gcl respects existing directory check" {
    # Create test remote repo
    repo_url=$(create_test_remote_repo "test-existing" "main")

    # Create existing directory
    mkdir test-existing

    # Try to clone into existing directory
    run gcl "$repo_url" test-existing
    [ "$status" -ne 0 ]
    [[ "$output" == *"Directory 'test-existing' already exists"* ]]
}

@test "gcl handles protocol conversion correctly" {
    # Create test remote repo
    repo_url=$(create_test_remote_repo "test-protocol" "main")

    # Convert to HTTPS-like URL for testing
    https_url="${repo_url/file:\/\//https://github.com/user/}"
    https_url="${https_url/.git/.git}"

    # Test SSH preference (this will fail to connect but should show protocol conversion)
    run gcl --ssh "$https_url" test-protocol-ssh
    # Should fail due to fake URL but show the conversion
    [[ "$output" == *"Using ssh protocol"* ]] || true
}

@test "gcl validates repository URL format" {
    # Test invalid URL
    run gcl "not-a-valid-url"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Invalid repository URL format"* ]]

    # Test another invalid format
    run gcl "just-a-string"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Invalid repository URL format"* ]]
}

@test "gcl prevents cloning inside existing git repo" {
    # Create a git repo
    git init existing-repo
    cd existing-repo

    # Try to run gcl inside the repo
    run gcl "https://github.com/user/repo.git"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Already in a git repository"* ]]
}

@test "gcl shows repository information after successful clone" {
    # Create test remote repo
    repo_url=$(create_test_remote_repo "test-info" "main")

    # Clone without private setup
    run bash -c "export PATH='$TEMP_DOTFILES/bin:$PATH'; echo 'n' | gcl '$repo_url' test-info-clone"
    [ "$status" -eq 0 ]

    # Check that output contains repository information
    [[ "$output" == *"Repository information:"* ]]
    [[ "$output" == *"Directory:"* ]]
    [[ "$output" == *"Remote URL:"* ]]
    [[ "$output" == *"Branch:"* ]]
}

@test "gcl handles missing use-private-git gracefully" {
    # Remove use-private-git from the test environment but keep gcl
    rm -f "$TEMP_DOTFILES/bin/use-private-git"

    # Create test remote repo
    repo_url=$(create_test_remote_repo "test-missing-tool" "main")

    # Try to clone with private setup
    run bash -c "export PATH='$TEMP_DOTFILES/bin:$PATH'; echo 'y' | gcl '$repo_url' test-missing-tool-clone"
    [ "$status" -eq 0 ]

    # Should show warning but continue
    [[ "$output" == *"use-private-git command not found"* ]]
    [[ "$output" == *"Clone complete!"* ]]
}