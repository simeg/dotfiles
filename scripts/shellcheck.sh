#!/usr/bin/env bash

# Run shellcheck on all bash files

find . -type f -name '*.sh' -exec shellcheck {} \;
find scripts/bin -type f ! -name '*.*' -exec file {} \; | grep -E '(shell|bash)' | cut -d: -f1 | xargs shellcheck
