SHELL := /bin/bash
QUAY_USER ?= $(shell whoami)
TAG ?= latest
IMG ?= quay.io/$(QUAY_USER)/kontainerized-kuttl:$(TAG)
.DEFAULT_GOAL := all

# Color and Formatting
RED =\e[91m#  Red color
GRN =\e[92m#  Green color
BLU =\e[96m#  Blue color
YLW =\e[93m#  Yellow color
BLD =\e[1m#   Bold
RST =\e[0m#   Reset format

# Targets
.PHONY: podman-build
podman-build:
	@echo -e "\nBuilding container image $(BLD)$(IMG)$(RST)..."
	podman build -t $(IMG) ./image

.PHONY: podman-push
podman-push:
	podman push $(IMG)

.PHONY: all
all: podman-build podman-push