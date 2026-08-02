# Optional installers for a local Debian/Ubuntu Linux environment.
#
# This Makefile is not used by GitHub Codespaces or Google Colab. GitHub owns
# the Codespaces editor and remote service; the repository's Codespaces entry
# point only installs the shell/CLI profile documented in ../README.md.

# Default target
.DEFAULT_GOAL := help

# Pinned upstream versions. See ../README.md before updating.
NPM_VERSION := 12.0.1
GTOP_VERSION := 1.1.5
DOCKER_GPG_SHA256 := 1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570
DOWNLOAD_VERIFIED := ../scripts/download-verified

.PHONY: help bootstrap jekyll docker neo4j

help :
	@echo "bootstrap     : Bootstrap Environment"
	@echo "jekyll        : Install Jekyll"
	@echo "docker        : Install Docker"

bootstrap:
	@echo "-> Bootstraping Environment"
	sudo apt update
	@echo "--> Installing required tools and utilities"
	sudo apt install build-essential httpie nano software-properties-common ca-certificates gnupg lsb-release
	@echo "--> Installing pinned NPM utilities (registry integrity is verified by npm)"
	npm install -g npm@$(NPM_VERSION)
	npm install -g gtop@$(GTOP_VERSION)
	@echo "-> Bootstrap Complete"

jekyll:
	@command -v jekyll >/dev/null 2>&1 && echo "jekyll already installed, skipping." && exit 0; \
	echo "-> Installing Ruby" && \
	sudo apt update && \
	sudo apt-get install ruby-full patch zlib1g-dev build-essential -y && \
	echo "-> Installing Jekyll and Bundler" && \
	gem install jekyll bundler

# Docker packages are authenticated by apt using the checksum-verified signing key.
docker:
	@command -v docker >/dev/null 2>&1 && echo "docker already installed, skipping." && exit 0; \
	echo "-> Installing Docker"; \
	$(DOWNLOAD_VERIFIED) https://download.docker.com/linux/ubuntu/gpg $(DOCKER_GPG_SHA256) /tmp/docker.gpg && \
	sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg /tmp/docker.gpg && \
	rm -f /tmp/docker.gpg && \
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
	sudo apt-get update && \
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Unsupported legacy placeholder: intentionally omitted from `make help`.
# It remains temporarily to avoid expanding this cleanup into a Neo4j redesign.
neo4j:
	@echo "-> Installing Neo4j"
	@echo "-> Neo4j installtion complete"
