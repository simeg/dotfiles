#!/bin/sh

function symlink_file_to_home {
  ln -sv "`pwd`/$1" $HOME
}

for dotfile in */.*; do
  # Ignore folders
  if [ -f "$dotfile" ]; then
    symlink_file_to_home $dotfile;
  fi
done

ln -sv `pwd`/vim $HOME/.vim
ln -sv `pwd`/bin $HOME/.bin

