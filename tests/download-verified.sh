#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

printf 'verified payload\n' > "$TEST_DIR/source"
checksum="$(sha256sum "$TEST_DIR/source" | cut -d ' ' -f 1)"
"$ROOT/scripts/download-verified" "file://$TEST_DIR/source" "$checksum" "$TEST_DIR/output"
cmp "$TEST_DIR/source" "$TEST_DIR/output"

if "$ROOT/scripts/download-verified" "file://$TEST_DIR/source" \
    0000000000000000000000000000000000000000000000000000000000000000 \
    "$TEST_DIR/rejected" 2>/dev/null; then
    echo "expected a checksum mismatch to fail" >&2
    exit 1
fi
[[ ! -e "$TEST_DIR/rejected" ]]
! find "$TEST_DIR" -name 'rejected.download-*' | grep -q .

echo "download-verified tests passed"
