# Default target
.DEFAULT_GOAL := help

# Pinned upstream revisions. See README.md before updating these values.
OH_MY_POSH_VERSION := 29.34.0
# Arch-specific SHA-256 digests for the oh-my-posh Linux binary.
# Update all three values when bumping OH_MY_POSH_VERSION.
OH_MY_POSH_LINUX_AMD64_SHA256 := 90f33e71f181e959f1511d03f05ee0843c5eab4d7799e2d479a13c3fdd5b7c44
OH_MY_POSH_LINUX_ARM64_SHA256 := f2b470d6b46ddea386730d081ce4a11aeb3a347ed54cda667815e70d8a4f5edb
OH_MY_POSH_LINUX_ARM_SHA256   := fbb9391daa3a6b7af5c184599c0fe2141d3ac5827461f5cdb2ac3d976675d158
OH_MY_ZSH_COMMIT := 59a9740721b734835812121322d6fe4827b0853a
ZSH_SYNTAX_HIGHLIGHTING_COMMIT := 1d85c692615a25fe2293bdd44b34c217d5d2bf04
ZSH_AUTOSUGGESTIONS_COMMIT := 85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5

# PHONY
.PHONY: windows linux win lin

help :
	@echo "windows : Bootstrap and install dotfiles for Windows"
	@echo "linux   : Bootstrap and install dotfiles for Linux"

win:
	@echo "Did you mean 'make windows'? Running it now..."
	$(MAKE) windows

lin:
	@echo "Did you mean 'make linux'? Running it now..."
	$(MAKE) linux

bootstrap-windows:
	powershell -ExecutionPolicy Bypass -File scripts/check-windows-prereqs.ps1
	@echo "-> Installing Powerline font Source Code Pro - https://github.com/powerline/fonts"
	powershell common/fonts/prerequisite.ps1
	powershell common/fonts/install.ps1
	@echo "-> Installing pinned oh-my-posh"
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install-windows-tools.ps1

windows: bootstrap-windows
	./install-profile windows

bootstrap-linux:
	@echo "Install Powerline font - Source Code Pro - https://github.com/powerline/fonts"
	sh common/fonts/install.sh
	@echo "-> Installing oh-my-posh $(OH_MY_POSH_VERSION) - https://ohmyposh.dev"
	@architecture=$$(uname -m); \
	case "$$architecture" in \
		x86_64)        omp_arch=amd64; checksum=$(OH_MY_POSH_LINUX_AMD64_SHA256) ;; \
		aarch64|arm64) omp_arch=arm64; checksum=$(OH_MY_POSH_LINUX_ARM64_SHA256) ;; \
		armv7l|armv6l) omp_arch=arm;   checksum=$(OH_MY_POSH_LINUX_ARM_SHA256)   ;; \
		*) echo "Unsupported architecture: $$architecture" >&2; exit 1 ;; \
	esac; \
	scripts/download-verified \
		https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v$(OH_MY_POSH_VERSION)/posh-linux-$$omp_arch \
		$$checksum /tmp/oh-my-posh
	sudo install -m 0755 /tmp/oh-my-posh /usr/local/bin/oh-my-posh
	rm -f /tmp/oh-my-posh
	@echo "Installing zsh and pinned oh-my-zsh plugins - https://ohmyz.sh"
	scripts/install-zsh.sh
	git clone https://github.com/ohmyzsh/ohmyzsh.git "${HOME}/.oh-my-zsh"
	git -C "${HOME}/.oh-my-zsh" checkout --detach $(OH_MY_ZSH_COMMIT)
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
	git -C "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" checkout --detach $(ZSH_SYNTAX_HIGHLIGHTING_COMMIT)
	git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
	git -C "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" checkout --detach $(ZSH_AUTOSUGGESTIONS_COMMIT)

linux: bootstrap-linux
	./install-profile linux
