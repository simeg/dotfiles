# Claude Code Slash Commands

This directory contains custom slash commands for Claude Code.

## What are slash commands?

Slash commands are custom prompts that can be invoked with `/command-name` in
Claude Code conversations. They allow you to create reusable, specialized
workflows.

## Available Commands

- `/add-vinyl` - Add a single album to Notion Vinylsamling database
- `/add-vinyls` - Add multiple albums to Notion Vinylsamling database
- `/initextra` - Initialize extra development tools and configurations
- `/update-record-shops-reviews` - Update record shop reviews in Notion

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
