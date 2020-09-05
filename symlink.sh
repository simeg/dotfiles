#!/usr/bin/env bash

symlink_file_to_home() {
  ln -sv "`pwd`/$1" $HOME
}

for dotfile in */.*; do
  # Ignore folders
  if [ -f "$dotfile" ]; then
    symlink_file_to_home "$dotfile"
  fi
done

ln -sv `pwd`/vim "$HOME"/.vim
ln -sv `pwd`/bin "$HOME"/.bin

# istat-menus
readonly ISTAT_CONF_FILE_PATH=`pwd`/istat-menus/com.bjango.istatmenus6.extras.plist
readonly ISTAT_CONF_FOLDER_PATH=/Users/simon/Library/Preferences

#ln -sv ${ISTAT_MENU_CONFIG_FILE_PATH} ${ISTAT_CONF_FOLDER_PATH}
