#!/usr/bin/env bash

# Installs brew

set -e

echo "Installing brew.."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
