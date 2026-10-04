#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  printf 'Usage: %s YOUR_USERNAME@YOUR_UBUNTU_HOST\n' "$0" >&2
  exit 2
fi

target="$1"
session="remote-agent-test-$$"
session_created=0

cleanup() {
  if [[ "$session_created" -ne 1 ]]; then
    return
  fi
  ssh "$target" bash -s -- "$session" <<'REMOTE_CLEANUP' >/dev/null 2>&1 || true
set -u
session="$1"
if command -v tmux >/dev/null 2>&1 && tmux has-session -t "$session" 2>/dev/null; then
  tmux kill-session -t "$session"
fi
REMOTE_CLEANUP
}

trap cleanup EXIT

printf '[INFO] Checking SSH and the remote Ubuntu host: %s\n' "$target"
ssh "$target" bash -s -- "$session" <<'REMOTE_START'
set -euo pipefail
session="$1"

if [[ ! -r /etc/os-release ]]; then
  printf '[ERROR] Remote host has no /etc/os-release.\n' >&2
  exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release
if [[ "${ID:-}" != 'ubuntu' ]]; then
  printf '[ERROR] Remote host is not Ubuntu: %s\n' "${PRETTY_NAME:-unknown}" >&2
  exit 1
fi

if [[ "${VERSION_ID:-}" != '24.04' ]]; then
  printf '[WARN] Remote Ubuntu version is %s; target is Ubuntu 24.04.4 LTS.\n' "${VERSION_ID:-unknown}"
else
  printf '[OK] Remote host: %s\n' "${PRETTY_NAME:-Ubuntu 24.04}"
fi

if ! command -v tmux >/dev/null 2>&1; then
  printf '[ERROR] tmux is missing on the remote host.\n' >&2
  exit 1
fi

if tmux has-session -t "$session" 2>/dev/null; then
  printf '[ERROR] Remote test session already exists: %s\n' "$session" >&2
  exit 1
fi

tmux new-session -d -s "$session" 'i=1; while [ "$i" -le 8 ]; do printf "remote-tick %s\n" "$i"; i=$((i + 1)); sleep 1; done'
printf '[OK] Created remote tmux session: %s\n' "$session"
REMOTE_START
session_created=1

printf '[INFO] The first SSH connection has ended. Waiting before reconnecting...\n'
sleep 2

output="$(ssh "$target" bash -s -- "$session" <<'REMOTE_CHECK'
set -euo pipefail
session="$1"
if ! tmux has-session -t "$session" 2>/dev/null; then
  printf '[ERROR] Remote tmux session disappeared: %s\n' "$session" >&2
  exit 1
fi
printf '[OK] Remote tmux session survived SSH disconnect: %s\n' "$session"
tmux capture-pane -p -t "$session:0.0" -S -20
REMOTE_CHECK
)"

printf '%s\n' "$output"
if ! grep -Eq 'remote-tick [2-8]' <<<"$output"; then
  printf '[ERROR] The task did not produce continued output after reconnecting.\n' >&2
  exit 1
fi

printf '[PASS] Ubuntu-to-Ubuntu SSH + tmux persistence test passed.\n'
