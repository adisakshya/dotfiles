#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

export HOME="${TEST_DIR}/home"
export DOTFILES_BACKUP_DIR="${TEST_DIR}/backups"
mkdir -p "$HOME/.config/example"
printf 'original bashrc\n' > "$HOME/.bashrc"
printf 'original settings\n' > "$HOME/.config/example/settings.json"

cat > "${TEST_DIR}/config.yaml" <<'EOF'
- link:
    ~/.bashrc: common/bash/.bashrc
    $HOME/.config/example/settings.json:
        path: common/example/settings.json
EOF

dry_run_output="$("${ROOT}/scripts/backup-dotfiles" --dry-run "${TEST_DIR}/config.yaml")"
[[ $dry_run_output == *"Would back up $HOME/.bashrc"* ]]
[[ $dry_run_output == *"Would back up $HOME/.config/example/settings.json"* ]]
[[ ! -e $DOTFILES_BACKUP_DIR ]]

"${ROOT}/scripts/backup-dotfiles" "${TEST_DIR}/config.yaml"
backup_run="$(find "$DOTFILES_BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d)"
[[ $(cat "$backup_run/.bashrc") == "original bashrc" ]]
[[ $(cat "$backup_run/.config/example/settings.json") == "original settings" ]]
[[ $(cat "$HOME/.bashrc") == "original bashrc" ]]
[[ $(cat "$HOME/.config/example/settings.json") == "original settings" ]]

failed_backup_root="${TEST_DIR}/not-a-directory"
printf 'occupied\n' > "$failed_backup_root"
if DOTFILES_BACKUP_DIR="$failed_backup_root" \
    "${ROOT}/scripts/backup-dotfiles" "${TEST_DIR}/config.yaml" >/dev/null 2>&1; then
    echo "expected an unwritable backup destination to fail" >&2
    exit 1
fi
[[ $(cat "$HOME/.bashrc") == "original bashrc" ]]

profile_output="$(HOME="$HOME" "${ROOT}/install-profile" --dry-run linux)"
[[ $profile_output == *"Would install profile linux"* ]]

standalone_output="$(HOME="$HOME" "${ROOT}/install-standalone" --check bash)"
[[ $standalone_output == *"Would install configs: bash"* ]]

! grep -q 'force:' "${ROOT}/meta/base.yaml"
grep -q 'force: true' "${ROOT}/meta/force-links-after-backup.yaml"

echo "backup-dotfiles tests passed"
