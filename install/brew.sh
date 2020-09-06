#!/usr/bin/env bash

# Installs brew, brew formulaes and casks

set -e

if ! command -v brew; then
  echo "Installing brew.."

  # Install brew
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  install_result=$?
  if [ "$install_result" -eq 0 ]; then
    echo "Sucessfully installed brew!"
  else
    echo "Error installing brew"
    exit 1
  fi
fi

readonly brew_deps=(
  git                               # git
  node                              # NodeJS
  ruby                              # Ruby (this comes with macOS, why is it needed?)
  tree                              # Display tree output
  yarn                              # JS dependency mananger
  perl                              # Perl
  scala                             # Scala
  sbt                               # Scala build tool
  fzf                               # Fuzzy finder
  heroku                            # Platform tool
  jq                                # JSON parser
  python                            # Python 3
  python@2                          # Python 2.7
  maven                             # Java build tool
  vim                               # Text editor
  bat                               # Improved `cat`
  ripgrep                           # Faster `grep
  fd                                # More useable `find`
  shellcheck                        # Check bash scripts for problems
  coreutils                         # GNU flavored utils
  grip                              # GitHub Markdown file previewer (dep. of vim plugin "vim-markdown-preview")
  httpie                            # HTTP client
  wifi-password                     # Find out the wifi password
)

readonly cask_deps=(
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

brew install "${brew_deps[@]}" &&
  echo "Brew setup complete"

brew cask install "${cask_deps[@]}" &&
  echo "Brew cask setup complete, a reboot is needed"

