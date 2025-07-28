#!/usr/bin/env zsh

########################################
# 📦 File Utilities
########################################

# Show the size of files/folders in human-readable format
fs() {
  local arg
  if du -b /dev/null &>/dev/null; then
    arg="-sbh"
  else
    arg="-sh"
  fi

  if (( $# > 0 )); then
    du $arg -- "$@"
  else
    # fallback to current folder and dotfiles
    # shellcheck disable=SC2086
    du $arg -- .[^.]* *
  fi
}

########################################
# ☕ Maven Helpers
########################################

# Run a Maven build for a specific module, skipping tests
check_maven_deps() {
  show_help() {
    cat <<EOF
Usage: check_maven_deps <module>

Runs 'mvn package' on a module, useful to verify dependency issues.

Options:
  -h, --help    Show this help message

Example:
  check_maven_deps my-module
EOF
  }

  if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    show_help
    return 0
  fi

  mvn package -DskipTests=true -am -pl :"$1"
}

# List all Maven module artifactIds under 'projections' and 'refinements'
list_maven_modules() {
  # Ensure we're inside a Maven project
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/pom.xml" ]]; then
      break
    fi
    dir="$(dirname "$dir")"
  done

  if [[ ! -f "$dir/pom.xml" ]]; then
    echo "error: not in a Maven project (pom.xml not found in any parent directory)." >&2
    return 1
  fi

  # Find and print artifactIds from pom.xml files
  find projections refinements -name pom.xml | while read -r pom; do
    xmlstarlet sel -t -v '/*[local-name()="project"]/*[local-name()="artifactId"]' "$pom"
    echo
  done
}
