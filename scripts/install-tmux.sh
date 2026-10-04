#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
  apt_get=(apt-get)
else
  apt_get=(sudo apt-get)
fi

if command -v tmux >/dev/null 2>&1; then
  printf '[OK] tmux already installed: %s\n' "$(tmux -V)"
  exit 0
fi

if [[ ! -r /etc/os-release ]]; then
  printf '[ERROR] Cannot identify the operating system.\n' >&2
  exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release
if [[ "${ID:-}" != 'ubuntu' ]]; then
  printf '[ERROR] This installer currently supports Ubuntu only.\n' >&2
  exit 1
fi

printf '[INFO] Installing tmux with apt.\n'
"${apt_get[@]}" update
"${apt_get[@]}" install -y tmux
printf '[OK] tmux installed: %s\n' "$(tmux -V)"
