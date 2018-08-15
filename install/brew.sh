#!/bin/sh

# Installs brew and brew cask packages, assumes brew is installed

set -e

readonly BREW_DEPS=(
  git
  node
  ruby
  tree
  yarn
  python                            # Python 3
  python@2                          # Python 2.7
  maven
  vim
  ack                               # grep but faster
  bat                               # cat but better
  ripgrep                           # grep written in rust, very fast
  fd                                # 'find' replacement in rust
  shellcheck                        # Check bash scripts for problems
  coreutils                         # GNU flavored utils
  ncdu                              # Disk usage analyzer with an ncurses interface
  grip                              # GitHub Markdown file previewer (dep. of vim plugin "vim-markdown-preview")
  httpie                            # HTTP client
)

readonly CASK_DEPS=(
  qlmarkdown                        # Quick look Finder plugin
  quicklook-json                    # Quick-look Finder plugin
  qlcolorcode                       # Quick-look Finder plugin
  qlstephen                         # Quick-look Finder plugin
  betterzipql                       # Quick-look Finder plugin
  qlimagesize                       # Quick-look Finder plugin
  qlvideo                           # Quick-look Finder plugin
  google-chrome                     # Browser
  atom                              # Editor
  pycharm                           # IDEA
  intellij-idea                     # IDEA
  webstorm                          # IDEA
  goland                            # IDEA
  jetbrains-toolbox                 # JetBrains utilities
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
  istat-menus                       # Menu bar stats
)


brew install "${BREW_DEPS[@]}" &&
  echo "Brew setup complete"

brew cask install "${CASK_DEPS[@]}" &&
  echo "Brew cask setup complete, a reboot is needed"

