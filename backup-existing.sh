#!/usr/bin/env bash

# Back up pre-existing dotfiles that would be managed by this repository.
# Copies are written to $HOME/.dotfiles-backups/<timestamp>-<pid>/ (or the
# directory named by $DOTFILES_BACKUP_DIR).
#
# Run this before the first install on a machine that already has dotfiles you
# want to keep.  The install scripts call the same backup logic automatically,
# but this script lets you inspect or trigger the backup step independently.
#
# Usage:
#   ./backup-existing.sh [--dry-run] --profile <profile>
#   ./backup-existing.sh [--dry-run] --configs <config>...
#
# Examples:
#   ./backup-existing.sh --dry-run --profile linux
#   ./backup-existing.sh --profile linux
#   ./backup-existing.sh --configs bash zsh essentials

set -euo pipefail

CONFIG_SUFFIX=".yaml"
META_DIR="meta"
CONFIG_DIR="configs"
PROFILES_DIR="profiles"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    echo "Usage: $0 [--dry-run] --profile <profile>" >&2
    echo "       $0 [--dry-run] --configs <config>..." >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  --dry-run   Show what would be backed up without copying anything" >&2
    echo "  --profile   Back up destinations for all configs in the named profile" >&2
    echo "  --configs   Back up destinations for the listed config name(s)" >&2
}

dry_run_flag=()
if [[ ${1:-} == "--dry-run" ]]; then
    dry_run_flag=(--dry-run)
    shift
fi

if (( $# == 0 )); then
    usage
    exit 2
fi

config_files=()

case "${1:-}" in
    --profile)
        shift
        if (( $# == 0 )); then
            echo "Error: --profile requires a profile name" >&2
            usage
            exit 2
        fi
        profile_file="${BASE_DIR}/${META_DIR}/${PROFILES_DIR}/$1"
        [[ -f "$profile_file" ]] || { echo "Unknown profile: $1" >&2; exit 1; }
        mapfile -t lines < "$profile_file"
        for config in "${lines[@]}"; do
            profileConfigName=${config//$'\t\r\n'/}
            [[ -n "$profileConfigName" ]] || continue
            config_files+=("${BASE_DIR}/${META_DIR}/${CONFIG_DIR}/${profileConfigName}${CONFIG_SUFFIX}")
        done
        ;;
    --configs)
        shift
        if (( $# == 0 )); then
            echo "Error: --configs requires at least one config name" >&2
            usage
            exit 2
        fi
        for config in "$@"; do
            config="${config%-sudo}"
            config_files+=("${BASE_DIR}/${META_DIR}/${CONFIG_DIR}/${config}${CONFIG_SUFFIX}")
        done
        ;;
    *)
        usage
        exit 2
        ;;
esac

if (( ${#config_files[@]} == 0 )); then
    echo "No config files resolved." >&2
    exit 1
fi

exec "${BASE_DIR}/scripts/backup-dotfiles" "${dry_run_flag[@]}" "${config_files[@]}"
