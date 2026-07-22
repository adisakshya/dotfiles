#!/usr/bin/env bash
# Install zsh using the system package manager.
# Supports apt-get (Debian/Ubuntu), dnf (Fedora/RHEL), pacman (Arch), and apk (Alpine).

set -euo pipefail

if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y zsh
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y zsh
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm zsh
elif command -v apk >/dev/null 2>&1; then
    sudo apk add --no-cache zsh
else
    echo "No supported package manager found (apt-get, dnf, pacman, apk)." >&2
    echo "Please install zsh manually before running 'make linux'." >&2
    exit 1
fi
