#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_root="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
dry_run=0

managed_paths=(
  ".tmux.conf"
  ".vimrc"
  ".wezterm.lua"
  ".config/btop"
  ".config/ghostty"
  ".config/nvim"
  ".config/yazi"
  ".config/zathura"
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
    return
  fi

  "$@"
}

action() {
  local message="$1"

  if (( dry_run )); then
    log "[dry-run] $message"
    return
  fi

  log "$message"
}

backup_target() {
  local target="$1"
  local relative="${target#$HOME/}"
  local destination="$backup_root/$relative"

  run mkdir -p "$(dirname "$destination")"
  run mv "$target" "$destination"
  action "backed up $target -> $destination"
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
  action "linked $target -> $source"
}

install_yazi_packages() {
  if [[ ! -f "$HOME/.config/yazi/package.toml" ]]; then
    return
  fi

  if ! command -v ya >/dev/null 2>&1; then
    log "warning: skipping Yazi packages because 'ya' is not installed"
    return
  fi

  if (( dry_run )); then
    action "would run 'ya pkg install' for Yazi packages"
    return
  fi

  if ya pkg install; then
    log "installed Yazi packages"
    return
  fi

  printf "warning: failed to install Yazi packages; run 'ya pkg install' later\n" >&2
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

  install_yazi_packages
}

main "$@"
