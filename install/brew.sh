#!/bin/sh

# Installs brew and brew cask packages, assumes brew is installed

set -e

brew_deps=(
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

cask_deps=(
  qlmarkdown                        # Quick look Finder plugin
  quicklook-json                    # Quick-look Finder plugin
  qlcolorcode                       # Quick-look Finder plugin
  qlstephen                         # Quick-look Finder plugin
  betterzipql                       # Quick-look Finder plugin
  qlimagesize                       # Quick-look Finder plugin
  qlvideo                           # Quick-look Finder plugin
  google-chrome                     # Browser
  atom                              # Editor
  docker                            # Virtual environment
  docker-toolbox                    # Docker utilities
  alfred                            # Spotlight with workflows
  vlc                               # Media streamer
  spectacle                         # Window management
  bartender                         # Menu bar item controller
  appzapper                         # App remover
  boom                              # Audio enhancer
  dashlane                          # Password manager
  dropbox                           # Cloud storage
  iterm2                            # Alternative to Terminal
  slack                             # Communication platform
  steam                             # Gaming platform
  unrarx                            # Decompression tool
  the-unarchiver                    # Decompression tool
  windscribe                        # VPN
)


brew install "${brew_deps[@]}" &&
  echo "Brew setup complete"

brew cask install "${cask_deps[@]}" &&
  echo "Brew cask setup complete, a reboot is needed"

