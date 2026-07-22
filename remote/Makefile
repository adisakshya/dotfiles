# Default target
.DEFAULT_GOAL := help

# Pinned upstream versions and checksums. See ../README.md before updating.
NPM_VERSION := 12.0.1
GTOP_VERSION := 1.1.5
LOCALTUNNEL_VERSION := 2.0.2
NGROK_VERSION := 5.0.0-beta.2
CODE_SERVER_VERSION := 4.129.0
CODE_SERVER_AMD64_SHA256 := 66160d99431595b0e9f4245abae8d0f472289fb77c97007ce79f2d64d06507f8
CODE_SERVER_ARM64_SHA256 := e504da34067eacc04e03265eccf90e5d2c3fdc3f06c91c2028a5a80f1d05a5b8
EXTENSION_PACK_VERSION := 1.0.0
EXTENSION_PACK_SHA256 := 40711c68fe626c202a2fc98f9916ec7e7c0db9d6538394d87d06d7a110d60615
DOCKER_GPG_SHA256 := 1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570
DOCKER_COMPOSE_VERSION := 5.3.1
DOCKER_COMPOSE_X86_64_SHA256 := f9ebc6ebdb19d769b793c245a736caaeb198c62587f13b25c660c13b4987f959
DOCKER_COMPOSE_AARCH64_SHA256 := aa611e811d0ea25897839c404bfb5bf93ce706dc51c500a4457890f5d0606a86
DOCKER_COMPOSE_ARMV6_SHA256 := 899607529e5e752cbdaec84b73e994378cf8f27f3d626a5a6df56f7511c00304
DOCKER_COMPOSE_ARMV7_SHA256 := 69276acb37ea70023cf85a8180e869c0cfc8cb5a3e672821400aa58dea56e2e8
DOCKER_COMPOSE_PPC64LE_SHA256 := 3280a0dcc7874c2a564ca1224c5669364bc1a5d83ae7153a9c0182fd76fd2102
DOCKER_COMPOSE_RISCV64_SHA256 := e237f165e0fd5472d147db274f0fb5dcdaab4384c36634178307f4c8e965d904
DOCKER_COMPOSE_S390X_SHA256 := 3889c8d1677bee347297c8f0a73bc517b5c35da18781812942aef8a87eac9011
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
	@architecture=$$(dpkg --print-architecture); \
	case "$$architecture" in \
		amd64) checksum=$(CODE_SERVER_AMD64_SHA256) ;; \
		arm64) checksum=$(CODE_SERVER_ARM64_SHA256) ;; \
		*) echo "Unsupported code-server architecture: $$architecture" >&2; exit 1 ;; \
	esac; \
	$(DOWNLOAD_VERIFIED) https://github.com/coder/code-server/releases/download/v$(CODE_SERVER_VERSION)/code-server_$(CODE_SERVER_VERSION)_$$architecture.deb "$$checksum" /tmp/code-server.deb
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
	@architecture=$$(uname -m); \
	case "$$architecture" in \
		x86_64) checksum=$(DOCKER_COMPOSE_X86_64_SHA256) ;; \
		aarch64) checksum=$(DOCKER_COMPOSE_AARCH64_SHA256) ;; \
		armv6l) architecture=armv6; checksum=$(DOCKER_COMPOSE_ARMV6_SHA256) ;; \
		armv7l) architecture=armv7; checksum=$(DOCKER_COMPOSE_ARMV7_SHA256) ;; \
		ppc64le) checksum=$(DOCKER_COMPOSE_PPC64LE_SHA256) ;; \
		riscv64) checksum=$(DOCKER_COMPOSE_RISCV64_SHA256) ;; \
		s390x) checksum=$(DOCKER_COMPOSE_S390X_SHA256) ;; \
		*) echo "Unsupported Docker Compose architecture: $$architecture" >&2; exit 1 ;; \
	esac; \
	$(DOWNLOAD_VERIFIED) https://github.com/docker/compose/releases/download/v$(DOCKER_COMPOSE_VERSION)/docker-compose-linux-$$architecture "$$checksum" /tmp/docker-compose
	sudo install -m 0755 /tmp/docker-compose /usr/local/bin/docker-compose
	rm -f /tmp/docker-compose

neo4j:
	@echo "-> Installing Neo4j"
	@echo "-> Neo4j installtion complete"
