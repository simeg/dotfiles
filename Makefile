.PHONY: all setup update validate test lint symlink clean health profile deps

all: setup

setup:
	./setup.sh

update:
	./update.sh

validate:
	./validate.sh

test:
	./tests/test_dotfiles.sh

test-quick:
	./tests/test_dotfiles.sh --quick

test-syntax:
	./tests/test_dotfiles.sh --syntax-only

ci: lint test

lint:
	./shellcheck.sh

symlink:
	./symlink.sh

clean:
	@echo "Removing symlinks..."
	@rm -f ~/.zshrc ~/.znap-plugins.zsh ~/.gitconfig ~/.gitignore ~/.vim ~/.ideavimrc ~/.bin ~/.config/starship.toml
	@echo "Symlinks removed"

health:
	./scripts/health-check.sh

health-quick:
	./scripts/health-check.sh --quick

profile:
	./scripts/profile-shell.sh

profile-startup:
	./scripts/profile-shell.sh --startup

deps:
	./scripts/check-deps.sh

deps-essential:
	./scripts/check-deps.sh --essential

