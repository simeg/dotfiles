#!/usr/bin/env bash

# Run shellcheck on all bash files
# Exit nonzero if shellcheck reports findings, so `make lint` and CI actually fail

status=0

# `-exec ... +` (unlike `\;`) makes find propagate shellcheck's exit status
find . -type f -name '*.sh' -not -path './.git/*' -exec shellcheck {} + || status=1

# bin/ scripts have no extension; detect shell scripts via file(1)
bin_scripts=$(find bin -type f ! -name '*.*' -exec file {} \; | grep -E '(shell|bash)' | cut -d: -f1)
if [[ -n "$bin_scripts" ]]; then
    # shellcheck disable=SC2086  # word splitting on filenames is intended; repo has no spaces in bin/
    echo "$bin_scripts" | xargs shellcheck || status=1
fi

exit "$status"
