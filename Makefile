SHELL := /bin/bash
USER_NAME = $(shell whoami)
TAG ?= "quay.io/$(USER_NAME)/kontainerized-kuttl"

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
	@echo -e "\nBuilding container image $(BLD)$(TAG)$(RST)..."
	podman build -t $(TAG) ./image