#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT

expected_profile=$'bash\nessentials'
[[ $(cat "$ROOT/meta/profiles/codespaces") == "$expected_profile" ]]

printf 'original bashrc\n' > "$TEST_HOME/.bashrc"

run_install() {
    HOME="$TEST_HOME" CODESPACES=true "$ROOT/install.sh"
}

first_output="$(run_install)"
[[ $first_output == *"Installed Bash and shared aliases/exports"* ]]
[[ -L $TEST_HOME/.bashrc && -L $TEST_HOME/.bash_profile ]]
[[ -L $TEST_HOME/.aliases && -L $TEST_HOME/.exports ]]
[[ ! -e $TEST_HOME/.zshrc && ! -e $TEST_HOME/adisakshya.yaml ]]
[[ $(find "$TEST_HOME/.dotfiles-backups" -type f -name .bashrc -exec cat {} \;) == "original bashrc" ]]

# An immediate rerun must succeed without creating another backup.
backup_count="$(find "$TEST_HOME/.dotfiles-backups" -type f | wc -l)"
run_install >/dev/null
[[ $(find "$TEST_HOME/.dotfiles-backups" -type f | wc -l) -eq $backup_count ]]

# A minimal interactive Bash must start cleanly without NVM or Oh My Posh.
shell_output="$(HOME="$TEST_HOME" PS1='$ ' bash --noprofile --rcfile "$TEST_HOME/.bashrc" -i -c 'printf shell-ok' 2>&1)"
[[ $shell_output == *shell-ok* ]]
[[ $shell_output != *"command not found"* ]]

echo "codespaces profile tests passed"
