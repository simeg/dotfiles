#!/usr/bin/env bash

############################################
# 💻 Language Toolchains
############################################

# Go
export GOPATH="$HOME/repos/go"
export GOBIN="$GOPATH/bin"

# Ruby (only add existing gem directories)
for ruby_version in 2.6.0 2.7.0 3.1.0; do
  if [[ -d "$HOME/.gem/ruby/$ruby_version/bin" ]]; then
    path+=("$HOME/.gem/ruby/$ruby_version/bin")
  fi
done

# Python (only add existing directories)
for python_dir in "$HOME/Library/Python/2.7/bin" "/usr/local/opt/python@3.7/bin"; do
  if [[ -d "$python_dir" ]]; then
    path+=("$python_dir")
  fi
done

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
path+=("/opt/homebrew/share/google-cloud-sdk/bin/gcloud")
path+=("/opt/homebrew/share/google-cloud-sdk/bin/docker-credential-gcloud")

############################################
# 🧰 Utilities & Custom Tools
############################################

# Custom utilities (only add existing directories)
for util_dir in "$HOME/.bin" "$HOME/bin" "/usr/local/opt/coreutils/libexec/gnubin" "/opt/spotify-devex/bin"; do
  if [[ -d "$util_dir" ]]; then
    path+=("$util_dir")
  fi
done

# make "idea" command available
path+=("/Applications/IntelliJ IDEA.app/Contents/MacOS")

