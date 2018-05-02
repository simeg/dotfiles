#!/bin/sh

set -e

# Installs brew packages that does not belong to any
# application, hence the name 'other'.

/usr/local/bin/brew install \
  git \
  node \
  ruby \
  tree \
  yarn \
  python \
  python3 \
  maven \
  ack \
  vim \
  ccat

