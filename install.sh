#!/usr/bin/env bash
# Dotfiles entrypoint used by GitHub Codespaces personalisation.
# Codespaces looks for install.sh, bootstrap.sh, setup.sh, or script/setup at
# the repository root and runs the first one it finds.
#
# This script is also safe to run on any Linux machine.  For a full local
# bootstrap that also installs oh-my-posh, oh-my-zsh, and fonts, run
# `make linux` instead.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Setting up dotfiles..."

# ------------------------------------------------------------------
# zsh
# Codespaces base images ship with zsh, so skip installation when it
# is already present to avoid an unnecessary sudo apt-get call.
# ------------------------------------------------------------------
if command -v zsh >/dev/null 2>&1; then
    echo "    zsh already installed, skipping."
else
    echo "    Installing zsh..."
    "$DOTFILES_DIR/scripts/install-zsh.sh"
fi

# ------------------------------------------------------------------
# Dotbot profile
# Initialises git submodules (which include Dotbot itself) and then
# creates the symlinks defined in meta/profiles/codespaces.
# ------------------------------------------------------------------
echo "==> Running Dotbot with the 'codespaces' profile..."
"$DOTFILES_DIR/install-profile" codespaces

echo "==> Dotfiles setup complete."
if [[ "${CODESPACES:-}" == "true" ]]; then
    echo "    Reload your shell or open a new terminal to apply changes."
fi
