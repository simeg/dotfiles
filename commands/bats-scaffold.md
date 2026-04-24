---
allowed-tools: Bash, Read, Write
description: Scaffold a new Bats test file under tests/bats/ following project conventions
---

# Scaffold a Bats test file

Given a target (a script in `scripts/` or `bin/`, or a config file under
`.config/`), create a new `tests/bats/<name>.bats` file.

1. **Pick a name** — derive from the target. E.g., `bin/repo-summary` →
   `tests/bats/test_repo_summary.bats`. Refuse if the file already exists.

2. **Read the conventions** — look at one existing file in `tests/bats/`
   (e.g., `test_configuration.bats`) for:
   - The `setup()` / `teardown()` patterns
   - Any `load` helpers from `setup_suite.bash`
   - Assertion style (bash test conditionals vs. bats-assert helpers)

3. **Generate three starter tests** matching that style:
   - **happy path** — invoke the target with valid inputs, assert success
   - **missing dependency** — stub or unset a dependency, assert sane
     failure (non-zero exit, useful error message)
   - **idempotency** — invoke twice, assert no side effects on the second
     call (or that the second call is a no-op)

4. **Run `bats tests/bats/<name>.bats`** to confirm it's discovered and
   the tests pass (or fail with the expected RED state if TDD-style).

5. **Run `make test`** to confirm the new file doesn't break the suite.

Report the file path and the bats output.
