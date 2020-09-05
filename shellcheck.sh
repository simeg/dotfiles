#!/usr/bin/env bash

# Run shellcheck on all bash files

fd -e "sh" -E "shellcheck.sh" | xargs shellcheck
