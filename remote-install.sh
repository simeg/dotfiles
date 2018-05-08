#!/bin/sh

git clone git@github.com:simeg/dotfiles.git ~/repos/dotfiles
pushd ~/repos/dotfiles
make full-install

