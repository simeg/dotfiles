#!/usr/bin/env bash

set -e

# Installs Rust. By installing with rustup it makes it easy to handle multiple
# version, including nightly. Using brew it's not that simple.

curl https://sh.rustup.rs -sSf | sh

