# Claude Code Slash Commands

This directory contains custom slash commands for Claude Code.

## What are slash commands?

Slash commands are custom prompts that can be invoked with `/command-name` in
Claude Code conversations. They allow you to create reusable, specialized
workflows.

## Available Commands

- `/add-vinyl` - Add a single album to Notion Vinylsamling database
- `/add-vinyls` - Add multiple albums to Notion Vinylsamling database
- `/audit-deps` - Audit freshness of all software in this dotfiles repo
  (brews, nvim plugins, znap plugins, runtime managers)
- `/bats-scaffold` - Scaffold a new Bats test file under `tests/bats/`
  following project conventions
- `/blame-prompt` - Debug Starship/zsh prompt issues — dump PROMPT, PATH,
  env, and recent shell config edits
- `/brewfile-sync` - Audit drift between Brewfile and installed packages in
  both directions
- `/initextra` - Initialize project with CLAUDE.md and create comprehensive
  feature documentation
- `/new-zsh-module` - Add a new zsh config module wired up end-to-end
  (file + symlink + sourcing + lint + smoke test)
- `/profile-shell` - Profile zsh startup and summarize what's slow
- `/theme-switch` - List, preview, or swap Starship themes
- `/update-record-shops-reviews` - Update record shop ratings and review
  counts in Notion
- `/verify-clean` - Run lint + tests + fresh-shell smoke test; only claims
  success if every step passes

## How it works

During `make setup`, these command files are symlinked from
`dotfiles/commands/` to `~/.claude/commands/`, making them available in all
Claude Code sessions.

## Creating new commands

1. Create a new `.md` file in this directory
2. Write your command prompt following the Claude Code slash command format
3. Run `make setup` or `./scripts/symlink.sh` to create the symlink
4. The command will be immediately available as `/your-command-name`

## File format

Commands are written in Markdown format. The content of the file becomes the
prompt that Claude Code executes when you invoke the command.

## Syncing across machines

Since these commands are part of your dotfiles:
- They're version controlled in git
- They sync automatically to new machines when you run `make setup`
- Changes are tracked and can be reviewed/reverted
