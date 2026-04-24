---
allowed-tools: Bash, Read, Write, Edit
description: Add a new zsh config module wired up end-to-end (file + symlink + sourcing + lint + smoke test)
---

# Add a new zsh module

Given a module name (and optionally body content), create the file under
`.config/zsh/<name>.zsh`, ensure it gets sourced, symlink it, and verify a
fresh shell loads cleanly.

1. **Confirm the name** — alphanumeric + dashes, no `.zsh` suffix in the
   user's input. Refuse names that conflict with existing modules.

2. **Create the file** at `.config/zsh/<name>.zsh` with `#!/usr/bin/env zsh`
   shebang and a comment block explaining the module's purpose. If body
   content was provided, include it; otherwise leave a TODO comment.

3. **Wire sourcing** — open `.config/zsh/.zshrc`. The existing pattern
   sources individual files explicitly (lines ~16–28). Add a matching
   `[[ -f "${HOME}/.config/zsh/<name>.zsh" ]] && source` line in the
   appropriate group (functions/exports/lazy-loading/aliases) — pick the
   group that matches the module's purpose.

4. **Symlink** — `ln -s "$(pwd)/.config/zsh/<name>.zsh" "$HOME/.config/zsh/<name>.zsh"`
   (the project's `scripts/symlink.sh` would also pick it up on next run,
   but the symlink ensures it's active immediately).

5. **Smoke test** — `zsh -i -c 'echo READY' 2>&1`; surface any errors.
   Then `make lint` to catch shellcheck issues.

6. Report the diff and confirm what's now active.
