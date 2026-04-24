---
allowed-tools: Bash, Read
description: Audit drift between Brewfile and installed packages in both directions
---

# Brewfile sync audit

Read-only check for drift between `install/Brewfile` and the local Homebrew
state. Do NOT auto-add or auto-remove anything — just report.

1. Run `brew bundle check --file=install/Brewfile --verbose` to see what
   the Brewfile expects but isn't installed.

2. Run `brew list --installed-on-request` and compare to `brew` lines in
   the Brewfile. Anything installed-on-request that's NOT in the Brewfile
   is candidate drift (might be a temporary install or a missing entry).

3. Cross-reference candidate drift against `scripts/analyze-package-usage.sh`
   output if it has run recently — flag truly-unused packages separately
   from "installed but not tracked".

4. Output two tables:
   - **In Brewfile, NOT installed**: `brew install` candidates
   - **Installed, NOT in Brewfile**: per-package, ask the user whether to
     add to Brewfile or `brew uninstall`. NEVER decide for them — these
     could be intentional experiments.

5. Mention any `brew "X"` and `brew "Y"` aliases (e.g., `kubectl` ==
   `kubernetes-cli`) that look like duplicates.
