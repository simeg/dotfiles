---
allowed-tools: Bash, Read
description: Run lint + tests + fresh-shell smoke test; refuse to claim success unless every step passes
---

# Verify clean

Run the full validation suite in parallel and only report success if EVERY step passes. Use this before claiming "I think it works".

1. Run these in parallel via separate Bash calls:
   - `make lint` (shellcheck across all shell scripts)
   - `make test` (Bats suite)
   - `zsh -i -c 'echo READY' 2>&1` (fresh interactive shell, capture stderr)
   - `zsh -i -c 'starship prompt --status=0 --cmd-duration=0 >/dev/null 2>&1; echo $?'` (prompt renders without warnings)

2. For each, report pass/fail and any new errors. If `make lint` reports new shellcheck warnings only on staged files, list them by file:line.

3. Refuse to claim success if ANY step failed. Diagnose the root cause; do not patch over it.

4. If all pass: print one short line ("All checks passed: lint, test, shell startup, prompt render") — no fluff.
