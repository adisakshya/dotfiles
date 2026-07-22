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

cat > "${TEST_DIR}/unrecognized.yaml" <<'EOF'
- link: { ~/.bashrc: common/bash/.bashrc }
EOF
if "${ROOT}/scripts/backup-dotfiles" "${TEST_DIR}/unrecognized.yaml" >/dev/null 2>&1; then
    echo "expected an unrecognized non-empty config to fail closed" >&2
    exit 1
fi

profile_output="$(HOME="$HOME" "${ROOT}/install-profile" --dry-run linux)"
[[ $profile_output == *"Would install profile linux"* ]]

standalone_output="$(HOME="$HOME" "${ROOT}/install-standalone" --check bash)"
[[ $standalone_output == *"Would install configs: bash"* ]]

! grep -q 'force:' "${ROOT}/meta/base.yaml"
grep -q 'force: true' "${ROOT}/meta/force-links-after-backup.yaml"

sudo_test_root="${TEST_DIR}/sudo-install"
sudo_caller_home="${TEST_DIR}/sudo-caller-home"
sudo_reset_home="${TEST_DIR}/sudo-reset-home"
mkdir -p "$sudo_test_root/scripts" "$sudo_test_root/meta/configs" \
    "$sudo_test_root/meta/dotbot/bin" "$sudo_test_root/fake-bin" \
    "$sudo_caller_home" "$sudo_reset_home"
cp "${ROOT}/install-standalone" "$sudo_test_root/"
cp "${ROOT}/scripts/backup-dotfiles" "$sudo_test_root/scripts/"
cp "${ROOT}/meta/base.yaml" "${ROOT}/meta/force-links-after-backup.yaml" \
    "$sudo_test_root/meta/"
cat > "$sudo_test_root/meta/configs/sudo-home.yaml" <<'EOF'
- link:
    $HOME/.sudo-home-test: source
EOF
printf 'caller data\n' > "$sudo_caller_home/.sudo-home-test"

cat > "$sudo_test_root/fake-bin/git" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat > "$sudo_test_root/fake-bin/sudo" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
export HOME=$SUDO_RESET_HOME
if [[ ${1:-} == HOME=* ]]; then
    export "${1}"
    shift
fi
exec "$@"
EOF
cat > "$sudo_test_root/meta/dotbot/bin/dotbot" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$HOME" > "$DOTBOT_HOME_RESULT"
EOF
chmod +x "$sudo_test_root/fake-bin/git" "$sudo_test_root/fake-bin/sudo" \
    "$sudo_test_root/meta/dotbot/bin/dotbot"

sudo_backup_dir="${TEST_DIR}/sudo-backups"
HOME="$sudo_caller_home" DOTFILES_BACKUP_DIR="$sudo_backup_dir" \
    SUDO_RESET_HOME="$sudo_reset_home" \
    DOTBOT_HOME_RESULT="${TEST_DIR}/dotbot-home" \
    PATH="$sudo_test_root/fake-bin:$PATH" \
    "$sudo_test_root/install-standalone" sudo-home-sudo
sudo_backup_run="$(find "$sudo_backup_dir" -mindepth 1 -maxdepth 1 -type d)"
[[ $(cat "$sudo_backup_run/.sudo-home-test") == "caller data" ]]
[[ $(cat "${TEST_DIR}/dotbot-home") == "$sudo_caller_home" ]]
[[ ! -e "$sudo_reset_home/.sudo-home-test" ]]

echo "backup-dotfiles tests passed"
