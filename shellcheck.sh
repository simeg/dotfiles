#!/usr/bin/env bash

# Run shellcheck on all bash files

find . -type f -name '*.sh' ! -path '*/vim/*' -exec shellcheck {} \;
find bin -type f -exec shellcheck {} \;
