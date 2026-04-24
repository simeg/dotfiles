# Testing Framework

This repo's tests are written in [Bats](https://bats-core.readthedocs.io/)
and live in `tests/bats/`. Run them via the Makefile.

## Layout

```
tests/bats/
├── setup_suite.bash             # Shared Bats setup
├── test_configuration.bats      # Config integrity (zsh, nvim, git, starship)
├── test_advanced_config.bats    # Deeper configuration checks
├── test_security.bats           # Secret scanning, file perms, shell hardening
├── test_performance.bats        # Shell startup baselines, plugin load times
├── test_git_config_unit.bats    # Git config unit tests
├── test_git_private_config.bats # Private git config tests
├── test_gcl_integration_ci.bats # gcl integration (CI)
├── test_ci.bats                 # CI-specific tests (no symlinks required)
└── test_comprehensive.bats      # End-to-end orchestrator
```

## Running

```bash
make test           # Local Bats suite (excludes *_ci.bats)
make test-advanced  # Advanced suite: advanced_config + performance + security
make test-ci        # CI-compatible tests (no symlink dependencies)
make lint           # shellcheck across all shell scripts
```

Direct invocation, e.g. for debugging a single file:

```bash
bats tests/bats/test_security.bats
bats tests/bats/test_performance.bats --filter "startup"
```

## Adding a test

1. Drop a new `*.bats` file under `tests/bats/`.
2. Use `setup_suite.bash` for shared helpers.
3. CI-only tests should be named `*_ci.bats` so `make test` skips them
   locally but `make test-ci` picks them up.
4. Run `make test` and `make lint` before committing.

## Pre-commit

Secret scanning runs via [gitleaks](https://github.com/gitleaks/gitleaks)
through `.pre-commit-config.yaml`. After cloning, run:

```bash
pre-commit install
```
