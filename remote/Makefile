# Default target
.DEFAULT_GOAL := help

# Pinned upstream versions and checksums. See ../README.md before updating.
NPM_VERSION := 12.0.1
GTOP_VERSION := 1.1.5
LOCALTUNNEL_VERSION := 2.0.2
NGROK_VERSION := 5.0.0-beta.2
CODE_SERVER_VERSION := 4.129.0
CODE_SERVER_SHA256 := 66160d99431595b0e9f4245abae8d0f472289fb77c97007ce79f2d64d06507f8
EXTENSION_PACK_VERSION := 1.0.0
EXTENSION_PACK_SHA256 := 40711c68fe626c202a2fc98f9916ec7e7c0db9d6538394d87d06d7a110d60615
DOCKER_GPG_SHA256 := 1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570
DOCKER_COMPOSE_VERSION := 5.3.1
DOCKER_COMPOSE_SHA256 := f9ebc6ebdb19d769b793c245a736caaeb198c62587f13b25c660c13b4987f959
DOWNLOAD_VERIFIED := ../scripts/download-verified

.PHONY: bootstrap code jekyll docker neo4j

help :
	@echo "bootstrap : Bootstrap Environment"
	@echo "code      : Install Code Server"
	@echo "jekyll    : Install Jekyll"
	@echo "docker    : Install Docker"
	@echo "neo4j     : Install Neo4j"

bootstrap:
	@echo "-> Bootstraping Environment"
	sudo apt update
	@echo "--> Installing required tools and utilities"
	sudo apt install build-essential httpie nano software-properties-common ca-certificates gnupg lsb-release openssh-server
	@echo "--> Installing pinned NPM utilities (registry integrity is verified by npm)"
	npm install -g npm@$(NPM_VERSION)
	npm install -g gtop@$(GTOP_VERSION)
	npm install -g localtunnel@$(LOCALTUNNEL_VERSION)
	npm install -g ngrok@$(NGROK_VERSION)
	@echo "-> Bootstrap Complete"

code:
	@echo "-> Installing Code Server $(CODE_SERVER_VERSION)"
	$(DOWNLOAD_VERIFIED) https://github.com/coder/code-server/releases/download/v$(CODE_SERVER_VERSION)/code-server_$(CODE_SERVER_VERSION)_amd64.deb $(CODE_SERVER_SHA256) /tmp/code-server.deb
	sudo dpkg -i /tmp/code-server.deb
	rm -f /tmp/code-server.deb
	@echo "-> Installing Extension Pack $(EXTENSION_PACK_VERSION)"
	$(DOWNLOAD_VERIFIED) https://github.com/adisakshya/extension-pack/releases/download/v$(EXTENSION_PACK_VERSION)/adisakshya-extension-pack.vsix $(EXTENSION_PACK_SHA256) /tmp/adisakshya-extension-pack.vsix
	code-server --install-extension /tmp/adisakshya-extension-pack.vsix
	rm -f /tmp/adisakshya-extension-pack.vsix

jekyll:
	@echo "-> Installing Ruby"
	sudo apt update
	sudo apt-get install ruby-full patch zlib1g-dev build-essential -y
	@echo "-> Installing Jekyll and Bundler"
	gem install jekyll bundler

# Docker packages are authenticated by apt using the checksum-verified signing key.
docker:
	@echo "-> Installing Docker"
	$(DOWNLOAD_VERIFIED) https://download.docker.com/linux/ubuntu/gpg $(DOCKER_GPG_SHA256) /tmp/docker.gpg
	sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg /tmp/docker.gpg
	rm -f /tmp/docker.gpg
	@echo "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io
	@echo "-> Installing Docker Compose $(DOCKER_COMPOSE_VERSION)"
	$(DOWNLOAD_VERIFIED) https://github.com/docker/compose/releases/download/v$(DOCKER_COMPOSE_VERSION)/docker-compose-linux-x86_64 $(DOCKER_COMPOSE_SHA256) /tmp/docker-compose
	sudo install -m 0755 /tmp/docker-compose /usr/local/bin/docker-compose
	rm -f /tmp/docker-compose

neo4j:
	@echo "-> Installing Neo4j"
	@echo "-> Neo4j installtion complete"
