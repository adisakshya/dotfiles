#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REMOTE_MAKEFILE="$ROOT/remote/Makefile"

# Retired remote-access and browser-IDE installers must not return to the local
# optional tooling collection.
! grep -qiE 'openssh-server|ngrok|localtunnel|code-server' "$REMOTE_MAKEFILE"

# The public help output is an explicit allowlist. The unsupported Neo4j
# placeholder remains unadvertised until its future cleanup is scoped.
expected_help=$'bootstrap     : Bootstrap Environment\njekyll        : Install Jekyll\ndocker        : Install Docker'
[[ $(make --no-print-directory -C "$ROOT/remote" help) == "$expected_help" ]]

# Do not restore global shortcuts for the retired Playground/Colab workflow or
# the overly broad installer alias.
! grep -qE '^[[:space:]]*alias[[:space:]]+(playground|expose|ins)=' "$ROOT/.aliases"

echo "remote tooling checks passed"
