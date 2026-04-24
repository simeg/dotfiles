---
allowed-tools: Bash, Read
description: List, preview, or swap Starship themes
---

# Starship theme switch

Wraps the `bin/starship-theme` script with sensible defaults.

If the user named a theme:
1. Confirm the theme exists at `.config/starship/themes/<name>.toml`.
2. Run `starship-theme preview <name>` and show the rendered prompt.
3. Ask for confirmation; if yes, run `starship-theme set <name>` and
   confirm `starship-theme current` reports the new name.

If no theme name was given:
1. Run `starship-theme current` to show the active theme.
2. List the 5 themes most recently modified in `.config/starship/themes/`
   (use `ls -t` and limit to 5).
3. Offer to preview any of them.

Never edit `~/.config/starship.toml` directly — the symlink is managed by
`bin/starship-theme`.
