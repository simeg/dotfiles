#!/bin/sh
#
# Creates symlinks from all dotfiles in this
# folder to $HOME. If a dotfile already exists
# then that is backed up before a symlink is
# created. Also runs all setup scripts to
# install plugins.

#############################################
# Utility functions
#############################################

# Symlink absolute path from this folder
# to $HOME
function symlink {
  ln -sv "`pwd`/$1" $HOME
}

# Returns file name from path.
# Assumes input looks like: "folder/file"
function get_file_name {
  echo $(sed 's/.*\///g' <<< $1);
}

# Checks if file exists in root
function file_exist {
  FILE=$(get_file_name $1);

  if [ -f "$HOME/$FILE" ]; then
    # 0 = true
    return 0
  else
    # 1 = false
   return 1
  fi
}

# Moves file to root with ".bak" suffix
function backup {
  FILE=$(get_file_name $1);
  echo "####################################";
  echo "--- Backing up $FILE to $HOME/$FILE.bak ---";
  mv -v "$HOME/$FILE" "$HOME/$FILE.bak";
  echo "####################################";
}

#############################################
# Symlinks
#############################################

# Iterate over all dotfiles in this repo
for dotfile in */.*; do
  # Ignore folders
  if [ -f "$dotfile" ]; then
    if file_exist $dotfile; then
      backup $dotfile;
    fi
    symlink $dotfile;
  fi
done

# Symlink folders
ln -sv `pwd`/vim $HOME/.vim

#############################################
# Plugins
#############################################

source ./install/package-managers.sh
source ./install/brew-cask.sh
source ./install/other.sh
source ./install/zsh.sh
source ./install/oh-my-zsh.sh
source ./install/vim.sh
#source ./install/vundle.sh
source ./install/safe-rm/safe-rm.sh
source ./install/macOS/macOS.sh

#############################################
# Etc
#############################################

# Do not display "Last logged in ..." when
# creating new shell
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
