.PHONY: all setup update validate test test-quick test-syntax test-ci lint symlink clean health profile deps deps-essential deps-core

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

test-ci:
	./tests/test_ci.sh

ci: lint test-ci

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

deps-core:
	./scripts/check-deps.sh --core

