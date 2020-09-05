#!/usr/bin/env bash

# Run shellcheck on all bash files

find . -name '*.sh' ! -path '*/vim/*' -exec shellcheck {} \;
