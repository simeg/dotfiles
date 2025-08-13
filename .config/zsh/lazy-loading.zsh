#!/usr/bin/env zsh
########################################
# 🚀 Lazy Loading Configuration
# Defers initialization of slow tools until first use
########################################

# 🐍 Python - pyenv
if command -v pyenv &>/dev/null; then
  pyenv() {
    unset -f pyenv
    eval "$(command pyenv init -)"
    pyenv "$@"
  }
fi

# 📦 SDKMAN - Java/Scala version management
if [[ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  # Always create sdk wrapper, and only create others if not in PATH
  sdk() {
    unset -f sdk java scala sbt gradle mvn 2>/dev/null
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk "$@"
  }
  
  # Create wrappers for commands not already in PATH
  for cmd in java scala sbt gradle mvn; do
    if ! command -v $cmd &>/dev/null; then
      eval "$cmd() {
        unset -f sdk java scala sbt gradle mvn 2>/dev/null
        source '$HOME/.sdkman/bin/sdkman-init.sh'
        $cmd \"\$@\"
      }"
    fi
  done
fi

# 📚 Atuin - shell history sync
if command -v atuin &>/dev/null; then
  atuin() {
    unset -f atuin
    eval "$(command atuin init zsh)"
    atuin "$@"
  }
fi