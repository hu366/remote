#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

printf '[INFO] Installing the Ubuntu machine-layer tmux dependency.\n'
"$script_dir/install-tmux.sh"
printf '[INFO] Checking the resulting environment.\n'
"$script_dir/check-environment.sh"
printf '[INFO] No SSH keys, Tailscale credentials, agent accounts, or user files were changed.\n'
