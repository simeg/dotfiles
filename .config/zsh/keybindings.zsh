# Only for interactive zsh (prevents leaking into scripts)
[[ -o interactive ]] || return

# Make slash a word boundary so ⌥⌫ kills just the last path segment
typeset -g WORDCHARS='*?[]~=&;!#$%^(){}<>'

# (Optional) ensure Meta+Backspace maps to backward-kill-word
# Only add if you’ve customized keymaps; most setups don’t need this.
#bindkey -M emacs '^[^?' backward-kill-word
#bindkey -M viins '^[^?' backward-kill-word
