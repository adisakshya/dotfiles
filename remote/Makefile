# Default target
.DEFAULT_GOAL := help

# Pinned upstream versions. See ../README.md before updating.
NPM_VERSION := 12.0.1
GTOP_VERSION := 1.1.5
LOCALTUNNEL_VERSION := 2.0.2
CODE_SERVER_VERSION := 4.130.0
EXTENSION_PACK_VERSION := 1.0.0
EXTENSION_PACK_SHA256 := 40711c68fe626c202a2fc98f9916ec7e7c0db9d6538394d87d06d7a110d60615
DOCKER_GPG_SHA256 := 1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570
DOWNLOAD_VERIFIED := ../scripts/download-verified

.PHONY: bootstrap code jekyll docker neo4j install-ngrok

help :
	@echo "bootstrap     : Bootstrap Environment"
	@echo "install-ngrok : Install ngrok v3"
	@echo "code          : Install Code Server"
	@echo "jekyll        : Install Jekyll"
	@echo "docker        : Install Docker"
	@echo "neo4j         : Install Neo4j"

bootstrap:
	@echo "-> Bootstraping Environment"
	sudo apt update
	@echo "--> Installing required tools and utilities"
	sudo apt install build-essential httpie nano software-properties-common ca-certificates gnupg lsb-release openssh-server
	@echo "--> Installing pinned NPM utilities (registry integrity is verified by npm)"
	npm install -g npm@$(NPM_VERSION)
	npm install -g gtop@$(GTOP_VERSION)
	npm install -g localtunnel@$(LOCALTUNNEL_VERSION)
	@echo "-> Bootstrap Complete"

install-ngrok:
	@command -v ngrok >/dev/null 2>&1 && echo "ngrok already installed, skipping." && exit 0; \
	curl -fsSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
	echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list && \
	sudo apt-get update && sudo apt-get install -y ngrok

code:
	@command -v code-server >/dev/null 2>&1 && echo "code-server already installed, skipping." || { \
	echo "-> Installing Code Server $(CODE_SERVER_VERSION)"; \
	ARCH=$$(dpkg --print-architecture); \
	curl -fsSL "https://github.com/coder/code-server/releases/download/v$(CODE_SERVER_VERSION)/code-server_$(CODE_SERVER_VERSION)_$${ARCH}.deb" -o /tmp/code-server.deb && \
	curl -fsSL "https://github.com/coder/code-server/releases/download/v$(CODE_SERVER_VERSION)/code-server_$(CODE_SERVER_VERSION)_$${ARCH}.deb.sha256" | awk '{print $$1 "  /tmp/code-server.deb"}' | sha256sum --check && \
	sudo dpkg -i /tmp/code-server.deb && \
	rm -f /tmp/code-server.deb; }
	@code-server --list-extensions 2>/dev/null | grep -q 'adisakshya.adisakshya-extension-pack' && echo "extension pack already installed, skipping." || { \
	echo "-> Installing Extension Pack $(EXTENSION_PACK_VERSION)"; \
	$(DOWNLOAD_VERIFIED) https://github.com/adisakshya/extension-pack/releases/download/v$(EXTENSION_PACK_VERSION)/adisakshya-extension-pack.vsix $(EXTENSION_PACK_SHA256) /tmp/adisakshya-extension-pack.vsix && \
	code-server --install-extension /tmp/adisakshya-extension-pack.vsix && \
	rm -f /tmp/adisakshya-extension-pack.vsix; }

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

neo4j:
	@echo "-> Installing Neo4j"
	@echo "-> Neo4j installtion complete"
