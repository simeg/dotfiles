# Zsh Completions

This directory contains custom zsh completion scripts for dotfiles tools.

## Available Completions

### `_starship-theme`
Tab completion for the `starship-theme` command:

```bash
starship-theme <TAB>        # Shows: list, current, set, preview, backup, restore, add
starship-theme set <TAB>    # Shows available theme names: minimal, enhanced, simple, etc.
starship-theme preview <TAB> # Shows available theme names
```

## Installation

These completions are automatically installed when you run `make symlink` or `./scripts/symlink.sh`.

## Testing Completions

After symlinking, restart your shell or run:
```bash
# Clear completion cache and reload
rm ~/.zcompdump*
source ~/.zshrc

# Test completion
starship-theme <TAB>
starship-theme set <TAB>
```

## How It Works

1. Completion files are symlinked to `~/.config/zsh/completions/`
2. The `.zshrc` adds this directory to `$fpath`
3. Zsh automatically loads completions with the `_command_name` format
4. The `_starship-theme` function provides context-aware completion

## Adding New Completions

To add completion for a new command:

1. Create `_command-name` file in this directory
2. Follow zsh completion format (see `_starship-theme` as example)
3. Update `scripts/symlink.sh` to include the new completion
4. Update Makefile clean target to remove it