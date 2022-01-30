# Default target
.DEFAULT_GOAL := help

# PHONY
.PHONY: bootstrap code jekyll docker neo4j

# Targets

help :
	@echo "bootstrap : Bootstrap Environment"
	@echo "code      : Install Code Server"
	@echo "jekyll    : Install Jekyll"
	@echo "docker    : Install Docker"
	@echo "neo4j     : Install Neo4j"

# Initialize
bootstrap:
	@echo "-> Bootstraping Environment"
	sudo apt update
	@echo "--> Installing required tools and utilities"
	apt install \
		build-essential \
		httpie \
		nano \
		software-properties-common \
		ca-certificates \
		gnupg \
		lsb-release \
		openssh-server
	@echo "--> Updating NPM"
	npm install -g npm
	@echo "--> NPM Updated"
	@echo "--> Installing gtop - https://github.com/aksakalli/gtop"
	npm install -g gtop
	@echo "--> gtop installtion complete"
	@echo "--> Installing localtunnel - https://github.com/localtunnel/localtunnel"
	npm install -g localtunnel
	@echo "--> localtunnel installtion complete"
	@echo "--> Installing ngrok - https://ngrok.com"
	wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
	unzip ngrok-stable-linux-amd64.zip
	@echo "--> ngrok installtion complete"
	@echo "-> Bootstrap Complete"

# Install Code Server
code: bootstrap
	@echo "-> Installing Code Server - https://github.com/cdr/code-server"
	curl -fsSL https://code-server.dev/install.sh | sh
	@echo "-> Code Server installtion complete"
	@echo "-> Installing Extension Pack for VSCode - https://github.com/adisakshya/extension-pack"
	curl https://github.com/adisakshya/extension-pack/releases/latest/download/adisakshya-extension-pack.vsix -O -L
	code-server --install-extension adisakshya-extension-pack.vsix
	@echo "-> Extension Pack installation complete"

# Install Jekyll
jekyll:
	@echo "-> Installing Ruby"
	sudo apt update
	sudo apt-get install ruby-full patch zlib1g-dev build-essential -y
	@echo "-> Installing Jekyll and Bundler"
	gem install jekyll bundler
	@echo "-> Jekyll installtion complete"

# Install Docker
docker:
	@echo "-> Installing Docker"
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
		$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io
	@echo "-> Docker installtion complete"
	@echo "-> Installing Docker Compose"
	curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	@echo "-> Docker Compose installtion complete"

# Install Neo4j
neo4j:
	@echo "-> Installing Neo4j"
	@echo "-> Neo4j installtion complete"