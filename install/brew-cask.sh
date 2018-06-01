#!/bin/sh

set -e

# Installs brew cask packages, assumes brew is installed

/usr/local/bin/brew cask install \
  qlmarkdown \                       # Quick look Finder plugin
  quicklook-json \                   # Quick-look Finder plugin
  qlcolorcode \                      # Quick-look Finder plugin
  qlstephen \                        # Quick-look Finder plugin
  betterzipql \                      # Quick-look Finder plugin
  qlimagesize \                      # Quick-look Finder plugin
  qlvideo \                          # Quick-look Finder plugin
  google-chrome \                    # Browser
  atom \                             # Editor
  docker \                           # Virtual environment
  docker-toolbox \                   # Docker utilities
  alfred \                           # Spotlight with workflows
  vlc \                              # Media streamer
  spectacle \                        # Window management
  bartender \                        # Menu bar item controller
  appzapper \                        # App remover
  boom \                             # Audio enhancer
  dashlane \                         # Password manager
  dropbox \                          # Cloud storage
  iterm2 \                           # Alternative to Terminal
  slack \                            # Communication platform
  steam \                            # Gaming platform
  unrarx \                           # Decompression tool
  the-unarchiver \                   # Decompression tool
  windscribe \                       # VPN
&&
echo "Brew cask setup complete, a reboot is needed"

