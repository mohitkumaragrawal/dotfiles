#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_root="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
dry_run=0

managed_paths=(
  ".tmux.conf"
  ".wezterm.lua"
  ".config/ghostty"
  ".config/nvim"
  ".config/yazi"
)

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run]

Symlinks the managed dotfiles into $HOME.
Existing files or directories are moved into a timestamped backup directory.
EOF
}

log() {
  printf '%s\n' "$*"
}

run() {
  if (( dry_run )); then
    printf '[dry-run] %s\n' "$*"
    return
  fi

  "$@"
}

backup_target() {
  local target="$1"
  local relative="${target#$HOME/}"
  local destination="$backup_root/$relative"

  run mkdir -p "$(dirname "$destination")"
  run mv "$target" "$destination"
  log "backed up $target -> $destination"
}

link_path() {
  local relative="$1"
  local source="$repo_root/$relative"
  local target="$HOME/$relative"

  if [[ ! -e "$source" ]]; then
    printf 'missing source: %s\n' "$source" >&2
    return 1
  fi

  run mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink "$target")"
    if [[ "$current" == "$source" ]]; then
      log "ok $target"
      return
    fi
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    backup_target "$target"
  fi

  run ln -s "$source" "$target"
  log "linked $target -> $source"
}

main() {
  while (($#)); do
    case "$1" in
      --dry-run)
        dry_run=1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        printf 'unknown argument: %s\n' "$1" >&2
        usage >&2
        exit 1
        ;;
    esac
    shift
  done

  for relative in "${managed_paths[@]}"; do
    link_path "$relative"
  done
}

main "$@"
