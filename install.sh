#!/usr/bin/env bash
# Dotfiles entrypoint used by GitHub Codespaces personalisation.
# Codespaces looks for install.sh, bootstrap.sh, setup.sh, or script/setup at
# the repository root and runs the first one it finds.
#
# This script is also safe to run on any Linux machine. It intentionally
# installs configuration only: project runtimes and optional shell tools are
# owned by each repository's dev container.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Setting up dotfiles..."

# ------------------------------------------------------------------
# Font installation
# Install the Powerline font package so that Source Code Pro for
# Powerline renders correctly in the Codespaces integrated terminal,
# matching the font configured in the Windows Terminal profile.
# ------------------------------------------------------------------
if command -v apt-get >/dev/null 2>&1; then
    echo "==> Installing fonts-powerline..."
    sudo apt-get install -y --no-install-recommends fonts-powerline
fi

# ------------------------------------------------------------------
# Dotbot profile
# Initialises git submodules (which include Dotbot itself) and then
# creates the symlinks defined in meta/profiles/codespaces.
# ------------------------------------------------------------------
echo "==> Running Dotbot with the 'codespaces' profile..."
(cd "$DOTFILES_DIR" && ./install-profile codespaces)

echo "==> Dotfiles setup complete."
echo "    Installed Bash and shared aliases/exports; optional tools were not installed."
if [[ "${CODESPACES:-}" == "true" ]]; then
    echo "    Reload your shell or open a new terminal to apply changes."
fi
