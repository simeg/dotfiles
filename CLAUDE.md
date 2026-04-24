# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Primary Commands (via Makefile)
```bash
# Essential
make setup                 # Complete dotfiles setup (symlinks, packages, validation)
make setup-minimal         # Essential setup only (faster)
make update                # Update all components (git, packages, plugins)
make validate              # Verify all configurations are working correctly
make symlink               # Create symlinks only
make packages              # Install and sync packages from Brewfile
make clean                 # Remove broken symlinks and temporary files
make deps                  # Check all dependencies are installed
make lint                  # Run shellcheck on all shell scripts
make help                  # Show all available commands

# Tests (Bats)
make test                  # Run the local Bats suite
make test-advanced         # Advanced tests (performance + security)
make test-ci               # CI-compatible tests (no symlink dependencies)

# Health diagnostics
make health                # System diagnostics and health checks
make health-monitor        # Real-time system monitoring dashboard
make health-analytics      # Package usage and performance analytics
make health-profile        # Shell startup performance profiling
make snapshot              # Take system metrics snapshot
```

### Direct Script Usage
```bash
./scripts/setup.sh --help     # See all setup options
./scripts/validate.sh --zsh   # Validate only Zsh configuration
./scripts/update.sh --brew-only  # Update only Homebrew packages
```

## Gotchas

Things that have surprised contributors (you and me both) — read these first:

- **Starship git timeout warnings**: `/opt/spotify-devex/bin/git` is an OTel
  shim added by Spotify's dev-env-instrumentation that adds ~40ms per
  invocation. Starship calls git ~10x per prompt and trips the 500ms
  command_timeout. Fix lives in `.config/zsh/starship-fast-git.zsh` — it
  rewrites `PROMPT`/`RPROMPT` after `starship init` to route through a
  wrapper that prepends real git and silences timeout WARNs.
  Massive repos (e.g. services-pilot, ~325k files) still drop
  git_status because the underlying `git status --porcelain=2 --branch`
  takes seconds; this is intentional, not a bug.
- **Tests are Bats, not shell scripts**: live under `tests/bats/`, not
  `scripts/tests/`. Run `make test` / `make test-advanced`. The old
  `test_*.sh` files referenced in some docs were removed long ago.
- **Symlinks are per-file, not per-dir**: `scripts/symlink.sh` walks
  `.config/zsh/*` and links each file individually to `~/.config/zsh/`.
  Adding a new zsh module file is enough — the next `make setup` (or
  re-run of `symlink.sh`) picks it up automatically.
- **Language-runtime split**: `mise` manages node + python (replaces
  abandoned zsh-nvm and slow pyenv). `sdkman` keeps managing JVM
  ecosystem (Java, Scala, Maven, etc.). `rustup` manages Rust. Don't
  reinvent any of these splits.
- **`kubectl` formula = `kubernetes-cli`**: brew aliases them. Adding
  both to Brewfile triggers a duplicate warning.
- **Active Starship theme**: managed by `bin/starship-theme` (a wrapper
  that symlinks the chosen `.config/starship/themes/*.toml` to
  `~/.config/starship.toml`). To change themes, run `starship-theme set
  <name>`, not edit the symlink directly.
- **Pre-commit runs gitleaks on every commit**: don't bypass with
  `--no-verify` casually — the user's CLAUDE.md elsewhere explicitly
  bans this.
- **Many casks auto-update themselves** (notion, gcloud-cli,
  docker-desktop). `brew outdated --cask --greedy` will report stale
  metadata even when the running app is current. Don't blindly upgrade.

## Architecture

Stack: Zsh + znap + Starship; Neovim + Lazy.nvim (Lua); Homebrew via Brewfile;
mise for node + python; sdkman for JVM tooling; rustup for Rust. Tests are
Bats under `tests/bats/`. Per-feature deep-dives in `docs/development/features/`
(read on demand — not auto-loaded).

## Development Patterns

### Tool Aliases & Preferences
- `nvim` preferred over `vim` (aliased)
- `eza` instead of `ls`
- `smart-cat` instead of `cat` (uses glow for markdown)
- `kubecolor` instead of plain `kubectl`
- `mvnd` instead of `mvn` (faster Maven daemon)

### Private Configuration
Sensitive data goes in `~/.config/zsh/private.zsh` (gitignored, sourced late
in `.zshrc` so it can override anything else).
