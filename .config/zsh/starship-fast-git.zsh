#!/usr/bin/env zsh
# Two problems to fix in Starship on this machine:
#   1. PATH has /opt/spotify-devex/bin first, whose `git` is a ~40ms OTel
#      shim. Many calls per prompt trips the 500ms command_timeout.
#   2. Some repos (e.g. services-pilot, ~325k files) genuinely take
#      several seconds for `git status --porcelain=2 --branch`, regardless
#      of which git binary runs. Bumping command_timeout would hang the
#      prompt for seconds; instead we accept that git_status is dropped
#      and suppress the WARN that Starship prints on timeout.
#
# PROMPT embeds the absolute starship binary path, so a plain starship()
# function wrapper never fires — rewrite PROMPT/RPROMPT after init to
# route each render through a helper that prepends real git and silences
# timeout warnings. Interactive `git` still hits the wrapper.

if [[ -x /opt/homebrew/bin/git ]]; then
  _starship_fast_git() {
    PATH="/opt/homebrew/bin:$PATH" STARSHIP_LOG=error command starship "$@"
  }

  _starship_bin="${commands[starship]}"
  if [[ -n "$_starship_bin" ]]; then
    PROMPT="${PROMPT//$_starship_bin/_starship_fast_git}"
    RPROMPT="${RPROMPT//$_starship_bin/_starship_fast_git}"
  fi
  unset _starship_bin
fi
