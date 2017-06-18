#!/bin/bash
#
# Symlink safe-rm to be put on the path
#
# safe-rm makes sure sensitive folders will not be allowed to be removed
# Some folders comes with the code by default, but more can be added in
#
#   ~/.config/safe-rm
#
# safe-rm website: https://launchpad.net/safe-rm
# safe-rm code: http://bazaar.launchpad.net/~fmarier/safe-rm/trunk/files
# safe-rm is using GPLv3 which according to [1] is allowed to be used like this
#
# [1] https://www.gnu.org/licenses/quick-guide-gplv3.html

ln -sv $PWD/safe-rm /usr/local/bin/rm

# This folder should exist,
# but in case it doesn't it does not hurt to create it again
mkdir ~/.config

touch ~/.config/safe-rm
cat <<EOF > ~/.config/safe-rm 
/
EOF
