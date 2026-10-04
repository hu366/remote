# Remote Agent

Remote Agent is a portable workflow for remotely controlling your local
terminal, CLI tools, and AI agents from a phone or another computer.

中文说明：[README.zh-CN.md](README.zh-CN.md)

It is not a replacement for an AI agent. It provides the remote access and
persistent terminal foundation in which Shell, Git, Python, ROS2, build tools,
Codex, Claude, and other CLI applications can run.

```text
Phone or computer -> Tailscale/LAN -> SSH -> tmux -> Shell / tools / agents
```

## Current scope

The first implementation target is Ubuntu 24.04.4 LTS. A phone or another
computer can be the client, while the target Ubuntu computer owns the files and
runs the work. Machine setup is kept separate from project-specific
development environments so the workflow can move to another Ubuntu computer
later.

The repository provides:

- Ubuntu environment checks.
- An idempotent installer for tmux.
- Documentation for SSH, Tailscale, Android, tmux, and CLI agents.
- Ubuntu-to-Ubuntu connectivity and VS Code Remote-SSH guidance.
- A roadmap for a future Windows backend.

## Quick start on Ubuntu

Run the environment check:

```bash
./scripts/check-environment.sh
```

Install tmux if it is missing:

```bash
./scripts/install-tmux.sh
```

Create a persistent workspace:

```bash
tmux new -s work
```

Start any terminal task inside it, then detach with `Ctrl-b` followed by `d`.
Reconnect later with:

```bash
tmux ls
tmux attach -t work
```

The installer does not configure personal authentication, SSH keys, Tailscale,
or third-party agent accounts.

## Ubuntu-to-Ubuntu deployment

Use one Ubuntu computer as the target (computer B) and another as the client
(computer A). The target owns the project files and runs the commands.

On computer B, install the repository and machine-layer dependencies:

```bash
git clone git@github.com:YOUR_GITHUB_OWNER/remote-agent.git "$HOME/remote-agent"
cd "$HOME/remote-agent"
./scripts/check-environment.sh
./scripts/install-tmux.sh
```

If the check reports that the SSH server is missing, install and enable it on
computer B:

```bash
sudo apt update
sudo apt install openssh-server
sudo systemctl enable --now ssh
```

Authenticate Tailscale interactively on both computers if they are not on the
same LAN. Do not put a Tailscale auth key in the repository. From computer A,
first test ordinary SSH:

```bash
ssh YOUR_USERNAME@YOUR_UBUNTU_HOST
```

Then run the repository's disconnect/reconnect test from a clone on computer A:

```bash
./scripts/test-ubuntu-to-ubuntu.sh YOUR_USERNAME@YOUR_UBUNTU_HOST
```

For normal work, create a persistent session on computer B:

```bash
ssh YOUR_USERNAME@YOUR_UBUNTU_HOST
tmux new -s project-work
cd YOUR_PROJECT_PATH
```

Detach with `Ctrl-b`, then `d`, or run `tmux detach-client`. Reconnect later
with:

```bash
ssh YOUR_USERNAME@YOUR_UBUNTU_HOST
tmux attach -t project-work
```

The repository does not configure passwords, SSH keys, firewalls, Tailscale
accounts, or third-party agent accounts automatically.

## VS Code from computer A

Install VS Code and the Microsoft `Remote - SSH` extension on computer A.
Confirm that the SSH command above works, then choose
`Remote-SSH: Connect to Host...` and enter
`YOUR_USERNAME@YOUR_UBUNTU_HOST`. Open the project directory on computer B.

The VS Code interface runs on computer A. The source files, compiler, Python,
ROS2, extensions, and debug process run on computer B. Use tmux in the VS Code
terminal for long-running builds, logs, and CLI agents. VS Code Remote Tunnels
is an alternative transport when inbound SSH is unavailable; it is separate
from the Tailscale + SSH + tmux workflow.

## Remote Terminal Use Cases

The same remote terminal can be used for:

- Viewing logs and long-running processes.
- Running scripts and Python programs.
- Git operations.
- CMake or other builds.
- ROS2 commands.
- Shell administration that is safe for the user to perform.
- CLI agents such as Codex or Claude.

From a phone or another computer, connect to the target:

```bash
ssh YOUR_USERNAME@YOUR_TAILSCALE_HOST
tmux attach -t work
```

Tailscale provides the network path. SSH provides the terminal connection.
tmux keeps the local terminal workspace alive after SSH ends. The application
running inside tmux is responsible for its own behavior.

For computer-to-computer development, VS Code Remote - SSH runs the editor on
the client and the files, tools, extensions, and debugging process on the
target. See [Ubuntu-to-Ubuntu](docs/12-computer-to-computer.md) and [VS Code
remote development](docs/13-vscode.md).

## CLI agents

Run an agent as an application inside tmux:

```bash
export PATH="$HOME/.local/bin:$PATH"
tmux new -s codex
cd YOUR_PROJECT_PATH
codex
```

For Claude, use a separate session named `claude` and run `claude` in it.

Some installations put CLI binaries in `$HOME/.local/bin`. Non-interactive SSH
shells may not include that directory in `PATH`; check explicitly when needed:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Validation status

Validated on the first Ubuntu machine on 2026-09-13:

| Area | Result |
| --- | --- |
| Ubuntu 24.04.4 LTS | Passed |
| tmux 3.4 session persistence | Passed |
| SSH public-key login | Passed |
| SSH disconnect and reconnect with tmux | Passed |
| Tailscale-connected SSH path | Passed |
| Android SSH connection | Passed manually |
| Android network interruption and reconnect | Passed manually |
| Interactive CLI agent after reconnect | Passed manually |
| Ubuntu-to-Ubuntu SSH + tmux | Not yet validated on a second Ubuntu computer |
| VS Code Remote - SSH | Not yet validated on a second Ubuntu computer |
| Second-machine migration | Not yet validated |

Android checks were manual, not automated device tests. No credentials or
device-specific configuration are stored here.

## Documentation

- [Overview](docs/01-overview.md)
- [Remote terminal](docs/02-remote-terminal.md)
- [tmux guide](docs/03-tmux.md)
- [SSH guide](docs/04-ssh.md)
- [Tailscale guide](docs/05-tailscale.md)
- [Android workflow](docs/06-android.md)
- [AI agents](docs/07-ai-agents.md)
- [Portability](docs/08-portability.md)
- [Windows roadmap](docs/09-windows-roadmap.md)
- [Troubleshooting](docs/10-troubleshooting.md)
- [Ubuntu-to-Ubuntu](docs/12-computer-to-computer.md)
- [VS Code remote development](docs/13-vscode.md)

## Safety boundaries

Remote Agent does not recommend exposing SSH directly to the public Internet.
It does not change passwords, delete SSH keys, modify Tailscale ACLs, upload
credentials, or push to GitHub automatically.
