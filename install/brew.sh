#!/usr/bin/env bash

# Installs brew and brew cask packages, assumes brew is installed

set -e

readonly BREW_DEPS=(
  git
  node
  ruby
  tree
  yarn
  perl
  scala
  sbt
  fzf                               # Fuzzy finder
  heroku
  jq                                # JSON parser
  python                            # Python 3
  python@2                          # Python 2.7
  maven
  vim
  bat                               # cat but better
  ripgrep                           # grep written in rust, very fast
  fd                                # 'find' replacement in rust
  shellcheck                        # Check bash scripts for problems
  coreutils                         # GNU flavored utils
  grip                              # GitHub Markdown file previewer (dep. of vim plugin "vim-markdown-preview")
  httpie                            # HTTP client
  wifi-password                     # Find out the wifi password
)

readonly CASK_DEPS=(
  betterzipql                       # Quick-look Finder plugin
  google-chrome                     # Browser
  pycharm                           # IDEA
  intellij-idea                     # IDEA
  webstorm                          # IDEA
  docker                            # Virtual environment
  docker-toolbox                    # Docker utilities
  alfred                            # Spotlight with workflows
  vlc                               # Media streamer
  spectacle                         # Window management
  bartender                         # Menu bar item controller
  appzapper                         # App remover
  boom                              # Audio enhancer
  dashlane                          # Password manager
  iterm2                            # Alternative to Terminal
  slack                             # Communication platform
  steam                             # Gaming platform
  unrarx                            # Decompression tool
  the-unarchiver                    # Decompression tool
  windscribe                        # VPN
  istat-menus                       # Menu bar stats
)

brew install "${BREW_DEPS[@]}" &&
  echo "Brew setup complete"

brew cask install "${CASK_DEPS[@]}" &&
  echo "Brew cask setup complete, a reboot is needed"

