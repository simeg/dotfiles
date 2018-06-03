#!/bin/sh

source ./symlink.sh

source ./install/package-managers.sh
source ./install/brew.sh
source ./install/zsh.sh
source ./install/oh-my-zsh.sh
source ./install/vim.sh
source ./install/safe-rm/safe-rm.sh
source ./install/macOS/macOS.sh

# Do not display "Last logged in ..." when creating new shell
if [ ~/.hushlogin ]; then
  echo "~/.hushlogin already exist, will not create a new one";
else
  touch ~/.hushlogin
  cat <<EOF > ~/.hushlogin
  # The mere presence of this file in the home directory disables the system
  # copyright notice, the date and time of the last login, the message of the
  # day as well as other information that may otherwise appear on login.
  # See `man login`.
  EOF
fi
