#!/bin/sh

readonly SCRIPTS=(
  symlink.sh
  install/my-test.sh
  install/package-managers.sh
  install/brew.sh
  install/zsh.sh
  install/oh-my-zsh.sh
  install/vim.sh
  install/rust.sh
  install/macOS/macOS.sh
)

for script in "${SCRIPTS[@]}"; do
  source "$script"
done

echo "All install scripts run"

# Do not display "Last logged in ..." when creating new shell
readonly HUSH_LOGIN_FILE=$HOME/.hushlogin
if [ -f "$HUSH_LOGIN_FILE" ]; then
  echo "$HUSH_LOGIN_FILE already exist, will not create a new one";
else
  touch "$HUSH_LOGIN_FILE"
  cat <<EOF > "$HUSH_LOGIN_FILE"
# The mere presence of this file in the home directory disables the system
# copyright notice, the date and time of the last login, the message of the
# day as well as other information that may otherwise appear on login.
# See "man login".
EOF
fi
