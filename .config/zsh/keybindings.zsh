# Only for interactive zsh (prevents leaking into scripts)
[[ -o interactive ]] || return

# Make slash a word boundary so ⌥⌫ kills just the last path segment
typeset -g WORDCHARS='*?[]~=&;!#$%^(){}<>'

# Enable edit-command-line widget and bind to Ctrl+X Ctrl+E
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# (Optional) ensure Meta+Backspace maps to backward-kill-word
# Only add if you've customized keymaps; most setups don't need this.
#bindkey -M emacs '^[^?' backward-kill-word
#bindkey -M viins '^[^?' backward-kill-word
