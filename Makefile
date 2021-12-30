#!/usr/bin/env make --makefile

ifndef VERBOSE
	MAKEFLAGS+=--silent
endif

define HELP_MENU
Usage: make <env> <target> <target>...

Main targets:
  all                 Call the default targets. [dwarf2json pdbconv volatility3 volshell]
  help                Show this help.
  push                Push all Docker images.
  save                Save all Docker images as a compressed archive.

Development targets:
  dwarf2json          Build the Docker image for "dwarf2json".
  pdbconv             Build the Docker image for "pdbconv".
  volatility3         Build the Docker image for "volatility3".
  volshell            Build the Docker image for "volshell".

Refer to the documentation for use cases and examples.
endef

PRODUCT_AUTHOR=sk4la
PRODUCT_BUILD_COMMIT:=$(shell git log --max-count=1 --pretty=format:%H)
PRODUCT_BUILD_DATE:=$(shell TZ=Z date +"%FT%T%Z")
PRODUCT_NAME=volatility3-docker
PRODUCT_REPOSITORY=https://github.com/sk4la/volatility3-docker
PRODUCT_VERSION?=0.2.3

DOCKER_BIN=docker
DOCKER_FLAGS+=
DOCKER_REGISTRY?=docker.io
DOCKER_TAG=$(PRODUCT_VERSION)
DOCKER_USER?=$(PRODUCT_AUTHOR)

ALPINE_VERSION=3.15

INSTALL_PREFIX=/usr
INSTALL_USER=root

TARGETS:=$(wildcard dwarf2json pdbconv volatility3 volshell)

.PHONY: all dwarf2json help pdbconv push save volatility3 volshell

all: $(TARGETS)

$(TARGETS):
	$(DOCKER_BIN) image build \
		$(DOCKER_FLAGS) \
		--build-arg="ALPINE_VERSION=${ALPINE_VERSION}" \
		--build-arg="INSTALL_PREFIX=${INSTALL_PREFIX}" \
		--build-arg="INSTALL_USER=${INSTALL_USER}" \
		--build-arg="PRODUCT_AUTHOR=${PRODUCT_AUTHOR}" \
		--build-arg="PRODUCT_BUILD_COMMIT=${PRODUCT_BUILD_COMMIT}" \
		--build-arg="PRODUCT_BUILD_DATE=${PRODUCT_BUILD_DATE}" \
		--build-arg="PRODUCT_REPOSITORY=${PRODUCT_REPOSITORY}" \
		--build-arg="PRODUCT_VERSION=${PRODUCT_VERSION}" \
		--rm \
		--tag="$(DOCKER_REGISTRY)/$(DOCKER_USER)/$@:$(DOCKER_TAG)" \
		--tag="$(DOCKER_REGISTRY)/$(DOCKER_USER)/$@:latest" \
		$@

help:
	$(info $(HELP_MENU))

push:
	$(DOCKER_BIN) image push "$(DOCKER_REGISTRY)/$(DOCKER_USER)/dwarf2json:$(DOCKER_TAG)"
	$(DOCKER_BIN) image push "$(DOCKER_REGISTRY)/$(DOCKER_USER)/dwarf2json:latest"

	$(DOCKER_BIN) image push "$(DOCKER_REGISTRY)/$(DOCKER_USER)/pdbconv:$(DOCKER_TAG)"
	$(DOCKER_BIN) image push "$(DOCKER_REGISTRY)/$(DOCKER_USER)/pdbconv:latest"

	$(DOCKER_BIN) image push "$(DOCKER_REGISTRY)/$(DOCKER_USER)/volatility3:$(DOCKER_TAG)"
	$(DOCKER_BIN) image push "$(DOCKER_REGISTRY)/$(DOCKER_USER)/volatility3:latest"

	$(DOCKER_BIN) image push "$(DOCKER_REGISTRY)/$(DOCKER_USER)/volshell:$(DOCKER_TAG)"
	$(DOCKER_BIN) image push "$(DOCKER_REGISTRY)/$(DOCKER_USER)/volshell:latest"

save:
	$(DOCKER_BIN) image save \
		"$(DOCKER_REGISTRY)/$(DOCKER_USER)/dwarf2json:$(DOCKER_TAG)" \
		"$(DOCKER_REGISTRY)/$(DOCKER_USER)/pdbconv:$(DOCKER_TAG)" \
		"$(DOCKER_REGISTRY)/$(DOCKER_USER)/volatility3:$(DOCKER_TAG)" \
		"$(DOCKER_REGISTRY)/$(DOCKER_USER)/volshell:$(DOCKER_TAG)" \
		| gzip > "$(DOCKER_USER)-$(PRODUCT_NAME).tar.gz"
