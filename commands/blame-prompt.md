---
allowed-tools: Bash, Read
description: Debug Starship/zsh prompt issues — dump PROMPT, PATH, env, and recent shell config edits
---

# Debug the prompt

Use when the prompt does something weird — slow, garbled, missing info, warnings on every render.

Capture diagnostic state from a fresh interactive subshell and report findings:

1. **Active state** — `zsh -i -c 'print -r -- "PROMPT=$PROMPT"; print -r -- "RPROMPT=$RPROMPT"; print -r -- "STARSHIP_LOG=$STARSHIP_LOG"; type starship'`

2. **PATH ordering** — `zsh -i -c 'echo "$PATH"' | tr ":" "\n" | head -15`. Flag if `/opt/spotify-devex/bin` precedes `/opt/homebrew/bin` (it normally does, by design — confirm `.config/zsh/starship-fast-git.zsh` is rewriting `PROMPT`).

3. **Active Starship theme** — `readlink ~/.config/starship.toml` and `grep -E '^command_timeout|\[git_' "$(readlink ~/.config/starship.toml)"`.

4. **Render trace** — run `STARSHIP_LOG=trace zsh -i -c 'starship prompt --status=0 --cmd-duration=0' 2>&1 >/dev/null` from the user's current directory and grep for `WARN`, `timed out`, or per-module timings.

5. **Recent shell-config edits** — `git log --oneline -15 -- .config/zsh/ .config/starship/`.

Diagnose root cause from the data, not vibes. Reference the Gotchas section in CLAUDE.md (especially the spotify-devex shim story) before suggesting fixes.
