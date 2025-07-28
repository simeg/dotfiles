.PHONY: all setup update validate lint symlink

all: setup

setup:
	./setup.sh

update:
	./update.sh

validate:
	./validate.sh

ci: lint

lint:
	./shellcheck.sh

symlink:
	./symlink.sh

