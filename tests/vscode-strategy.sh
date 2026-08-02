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

# A dangling link from the former profile is materialized without touching a
# regular file or an unrelated symlink.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
export HOME="$tmpdir/home"
mkdir -p "$HOME/.config/Code/User" "$tmpdir/old/common/vscode"
destination="$HOME/.config/Code/User/settings.json"
ln -s "$tmpdir/old/common/vscode/settings.json" "$destination"
"$ROOT/scripts/migrate-vscode-settings"
[[ -f $destination && ! -L $destination ]]
cmp "$ROOT/scripts/migrations/vscode-settings.json" "$destination"

printf '{"keep":true}\n' > "$destination"
"$ROOT/scripts/migrate-vscode-settings"
grep -q '"keep":true' "$destination"

rm "$destination"
ln -s "$tmpdir/unrelated/settings.json" "$destination"
"$ROOT/scripts/migrate-vscode-settings"
[[ -L $destination ]]

# Guard the documented boundary against accidentally restoring either legacy
# code-server installation or extension-pack installation.
! grep -qE 'code-server|adisakshya-extension-pack' "$ROOT/remote/Makefile"
grep -q 'Settings Sync is the source of truth' "$ROOT/README.md"
grep -q 'customizations.vscode.extensions' "$ROOT/README.md"

echo "VS Code strategy tests passed"
