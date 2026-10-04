#!/usr/bin/env bash
set -u

warnings=0

ok_msg() { printf '[OK] %s\n' "$1"; }
info_msg() { printf '[INFO] %s\n' "$1"; }
warn_msg() { printf '[WARN] %s\n' "$1"; warnings=$((warnings + 1)); }
missing_msg() { printf '[MISSING] %s\n' "$1"; warnings=$((warnings + 1)); }

printf 'Remote Agent environment check\n'
printf '==============================\n'

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  if [[ "${ID:-}" == 'ubuntu' && "${VERSION_ID:-}" == '24.04' ]]; then
    ok_msg "${PRETTY_NAME:-Ubuntu 24.04}"
  elif [[ "${ID:-}" == 'ubuntu' ]]; then
    warn_msg "Ubuntu ${VERSION_ID:-unknown}; target is Ubuntu 24.04.4 LTS"
  else
    warn_msg "${PRETTY_NAME:-unknown operating system}; target is Ubuntu 24.04.4 LTS"
  fi
else
  missing_msg '/etc/os-release'
fi

if command -v uname >/dev/null 2>&1; then
  ok_msg "Architecture: $(uname -m)"
else
  missing_msg 'uname'
fi

check_command() {
  local label="$1"
  local command_name="$2"
  local version_output
  if command -v "$command_name" >/dev/null 2>&1; then
    case "$command_name" in
      tmux|ssh)
        version_output="$($command_name -V 2>&1 | head -n 1)"
        ;;
      *)
        version_output="$($command_name --version 2>&1 | head -n 1)"
        ;;
    esac
    ok_msg "$label: $version_output"
  else
    missing_msg "$label ($command_name)"
  fi
}

check_command 'tmux' tmux
check_command 'SSH client' ssh
check_command 'Git' git
check_command 'Python' python3

if command -v sshd >/dev/null 2>&1; then
  if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet ssh.socket 2>/dev/null; then
    ok_msg 'SSH server: installed and ssh.socket is active'
  else
    warn_msg 'SSH server: installed but ssh.socket is not active'
  fi
else
  missing_msg 'SSH server (openssh-server)'
fi

if command -v tailscale >/dev/null 2>&1; then
  if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet tailscaled 2>/dev/null; then
    ok_msg "Tailscale: $(tailscale version 2>/dev/null | head -n 1), daemon active"
  else
    warn_msg 'Tailscale installed but tailscaled is not active'
  fi
else
  missing_msg 'Tailscale'
fi

find_local_cli() {
  local command_name="$1"
  if command -v "$command_name" >/dev/null 2>&1; then
    command -v "$command_name"
  elif [[ -x "$HOME/.local/bin/$command_name" ]]; then
    printf '%s\n' "$HOME/.local/bin/$command_name"
  else
    return 1
  fi
}

for cli in codex claude; do
  if cli_path="$(find_local_cli "$cli")"; then
    info_msg "$cli detected at $cli_path"
  else
    info_msg "$cli CLI not detected; optional"
  fi
done

printf '\nSummary: %d warning(s)\n' "$warnings"
printf '[INFO] This check does not authenticate accounts or modify configuration.\n'
exit 0
