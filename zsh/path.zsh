#!/usr/bin/env bash

############################################
# 💻 Language Toolchains
############################################

# Go
export GOPATH="$HOME/repos/go"
export GOBIN="$GOPATH/bin"

# Ruby (multiple versions)
path+=(
  "$HOME/.gem/ruby/2.6.0/bin"
  "$HOME/.gem/ruby/2.7.0/bin"
  "$HOME/.gem/ruby/3.1.0/bin"
)

# Python
path+=(
  "$HOME/Library/Python/2.7/bin"
  "/usr/local/opt/python@3.7/bin"
)

# Rust
path+=("$HOME/.cargo/bin")

# Node.js
path+=("/usr/local/bin")

# pyenv fallback
if ! command -v pyenv >/dev/null && [[ -n "$PYENV_ROOT" ]]; then
  path+=("$PYENV_ROOT/bin")
fi

############################################
# ☁️ Cloud SDKs
############################################

path+=("/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin")
[[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]] && source "$HOME/google-cloud-sdk/path.zsh.inc"

############################################
# 🧰 Utilities & Custom Tools
############################################

path+=(
  "$HOME/.bin"
  "$HOME/bin"
  "/usr/local/opt/coreutils/libexec/gnubin"
  "/opt/spotify-devex/bin"
)
