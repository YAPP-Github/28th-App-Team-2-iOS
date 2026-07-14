.PHONY: setup

all: setup

setup:
	@chmod +x scripts/setup-env.sh
	@./scripts/setup-env.sh
