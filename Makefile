SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# help: @ Lists available make tasks
help:
	@egrep -oh '[0-9a-zA-Z_\.\-]+:.*?@ .*' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

stop-container:
	@if [[ "$(shell docker ps -q -f name=web-tibert)" != "" ]]; then \
		bash -c "docker container stop web-tibert"; \
		echo "Container stopped..."; \
	fi

remove-container: stop-container
	@if [[ "$(shell docker ps -aq -f status=exited -f name=web-tibert)" != "" ]]; then \
		bash -c "docker container rm web-tibert"; \
		bash -c "docker image rm web-tibert"; \
		echo "Container removed, Image removed..."; \
	fi

# clean: @ Removes the build container and image
.PHONY: clean
clean: remove-container
	@echo "Cleaning complete..."

# build: @ Creates the image and container 
build: clean
	@if [[ "$(shell docker ps -q -f name=web-tibert)" = "" ]]; then \
		bash -c "docker build -t web-tibert ."; \
		bash -c "docker run -it -d --name web-tibert -p 80:80 web-tibert"; \
		echo "Build complete..."
	fi
