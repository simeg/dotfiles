#!/bin/sh

set -e

apps=(
  git
  node
  ruby
  tree
  yarn
  python                    # Python 3
  python@2                  # Python 2.7
  maven
  vim
  ack                       # grep but faster
  bat                       # cat but better
  shellcheck                # Check bash scripts for problems
)

brew install "${apps[@]}" && echo "Brew setup complete"

