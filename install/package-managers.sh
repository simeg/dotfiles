#!/bin/sh

# Installs brew, assumes Ruby is installed

# Is Brew already installed? Then don't install it again
which -s brew
if [[ $? -eq 0 ]]; then
  echo "Brew is already installed, will not install again";
  exit 0;
fi

# Install brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";

install_result=$?
if [ "$install_result" -eq 0 ]; then
  echo "Sucessfully installed brew";
  exit 0;
else
  exit 1;
fi

