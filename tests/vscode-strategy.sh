#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Settings Sync, rather than a Dotbot profile or copy operation, owns personal
# VS Code state on every platform.
for profile in codespaces linux windows; do
    ! grep -qx 'vscode' "$ROOT/meta/profiles/$profile"
done
[[ ! -e "$ROOT/meta/configs/vscode.yaml" ]]
! grep -q 'Code.User.settings.json' <(tr '\\' '.' < "$ROOT/scripts/install-windows-copy.ps1")

# Guard the documented boundary against accidentally restoring either legacy
# code-server installation or extension-pack installation.
! grep -qE 'code-server|adisakshya-extension-pack' "$ROOT/remote/Makefile"
grep -q 'Settings Sync is the source of truth' "$ROOT/README.md"
grep -q 'customizations.vscode.extensions' "$ROOT/README.md"

echo "VS Code strategy tests passed"
