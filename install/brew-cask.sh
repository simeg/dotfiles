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
  docker \
  docker-toolbox \
  alfred \
  vlc \
  spectacle \
  bartender \
  appzapper \
  boom \
  dashlane \
  dropbox \
  iterm2 \
  slack \
  steam \
  unrarx \
  the-unarchiver \
  windscribe \
&&
echo "Brew cask setup complete, a reboot is needed"

