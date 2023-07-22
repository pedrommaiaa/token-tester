# Ignore instructions clashing with directory names
.PHONY: test docs book

# Include .env file and export its variables
-include .env

build:; forge build

test:; ./scripts/test.sh -p "default"
test-tokens:; ./scripts/test.sh -p "token"