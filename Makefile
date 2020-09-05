.PHONY: all lint remote setup symlink

ci: lint

lint:
	./shellcheck.sh

remote:
	./remote-setup.sh

setup:
	./setup.sh

symlink:
	./symlink.sh

