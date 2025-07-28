#!/usr/bin/env bash

# Run shellcheck on all bash files

find . -type f -name '*.sh' ! -path '*/vim/*' -exec shellcheck {} \;
find bin -type f ! -name '*.*' -exec file {} \; | grep -E '(shell|bash)' | cut -d: -f1 | xargs shellcheck
