#!/bin/sh
#
# Creates symlinks from all dotfiles in this
# folder to $HOME. If a dotfile already exists
# then that is backed up before a symlink is
# created.

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
# Logic
#############################################

# Iterate over all dotfiles
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
ln -sfv `pwd`/vim $HOME/.vim

# Run installation scripts
#source ./install/zsh.sh
#source ./install/vundle.sh
