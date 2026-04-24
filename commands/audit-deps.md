---
allowed-tools: Bash, Read, Agent
description: Audit freshness of all software in this dotfiles repo (brews, nvim plugins, znap plugins, runtime managers)
---

# Audit dotfiles freshness

Run a parallel audit across all categories of software managed by this repo and report what's stale.

Spawn three subagents in parallel (general-purpose), each with read-only access:

1. **Homebrew audit** — run `brew update` once, then `brew outdated --verbose` and `brew outdated --cask --verbose --greedy`. Compare to `install/Brewfile`. Report stale formulas, stale casks (with bump severity), any Brewfile entries missing locally, and any locally-installed-on-request packages NOT tracked in Brewfile.

2. **Neovim plugin audit** — read `.config/nvim/lazy-lock.json`, resolve each plugin spec from `.config/nvim/lua/plugins/lazy.lua`, and for each compare the pinned commit SHA to the upstream default-branch HEAD on GitHub. Report plugins >30 days behind and any that have been archived. Use `git ls-remote` and patch fetches (NOT GitHub API) to avoid rate limits.

3. **Zsh + runtime managers** — for each znap plugin in `.config/zsh/.znap-plugins.zsh`, compare local HEAD to upstream HEAD. For runtime managers (mise, sdkman, rustup, pyenv if present, nvm if present), check installed version vs. latest stable.

Consolidate into a single report grouped by:
- 🟢 **Clean** (everything current)
- 🟡 **Minor** (one-line bumps)
- 🟠 **Worth attention** (major-version-style bumps, abandoned upstreams)
- 🔴 **Structural** (archived repos, abandoned plugins needing replacement)

Do NOT make any changes — this is read-only. Suggest concrete next-step commands for each item but wait for the user to choose what to upgrade.
