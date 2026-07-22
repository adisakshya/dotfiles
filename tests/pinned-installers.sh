#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

! grep -E -- '--remote|releases/latest|raw\.githubusercontent\.com/.*/master|curl[^|]*\|[[:space:]]*(sh|bash)|iwr[^|]*\|' \
    "$ROOT/Makefile" "$ROOT/remote/Makefile" "$ROOT/install-profile" \
    "$ROOT/install-standalone" "$ROOT/scripts/install-windows-tools.ps1"
grep -q 'sha256sum --check' "$ROOT/scripts/download-verified"
grep -q 'Get-FileHash -Algorithm SHA256' "$ROOT/scripts/install-windows-tools.ps1"
grep -q "SetEnvironmentVariable('Path', \$UpdatedUserPath, 'User')" \
    "$ROOT/scripts/install-windows-tools.ps1"

remote_makefile="$ROOT/remote/Makefile"
grep -q 'architecture=$$(dpkg --print-architecture)' "$remote_makefile"
grep -q 'CODE_SERVER_ARM64_SHA256' "$remote_makefile"
grep -q 'architecture=$$(uname -m)' "$remote_makefile"
grep -q 'DOCKER_COMPOSE_AARCH64_SHA256' "$remote_makefile"

echo "pinned installer checks passed"
