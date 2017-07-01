#!/bin/sh

set -e

# Installs brew cask packages, assumes brew is installed

/usr/local/bin/brew cask install \
  qlmarkdown \
  quicklook-json \
  qlcolorcode \
  qlstephen \
  betterzipql \
  qlimagesize \
  qlvideo \
  google-chrome \
  atom \
&&
echo "Brew cask setup complete, a reboot is needed"

