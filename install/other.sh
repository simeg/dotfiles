#!/bin/sh

set -e

# Installs brew packages that does not belong to any
# application, hence the name 'other'.

# Sanity check. Is brew installed on the system? If not - install it
type brew >/dev/null 2>&1 || {
  echo >&2 "Could not find brew. Installing it";
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
  exit 1;
}

/usr/local/bin/brew install \
  git \
  node \
  ruby \
  tree \
  yarn \
  python \
  python3
