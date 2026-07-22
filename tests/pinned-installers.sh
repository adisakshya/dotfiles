#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

! grep -E -- '--remote|releases/latest|raw\.githubusercontent\.com/.*/master|curl[^|]*\|[[:space:]]*(sh|bash)|iwr[^|]*\|' \
    "$ROOT/Makefile" "$ROOT/remote/Makefile" "$ROOT/install-profile" \
    "$ROOT/install-standalone" "$ROOT/scripts/install-windows-tools.ps1"
grep -q 'sha256sum --check' "$ROOT/scripts/download-verified"
grep -q 'Get-FileHash -Algorithm SHA256' "$ROOT/scripts/install-windows-tools.ps1"

echo "pinned installer checks passed"
