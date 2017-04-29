#!/bin/sh
#
# Installs brew packages that does not belong to any
# application, hence the name 'other'.

# Sanity check. Is brew installed on the system?
type brew >/dev/null 2>&1 || {
  echo >&2 "Could not find brew. Installing it";
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
  exit 1;
}

brew install \
  git \
  node \
  ruby \
  tree \
  yarn 
