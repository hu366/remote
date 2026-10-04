# Ubuntu-to-Ubuntu

Remote Agent is not limited to a phone as the SSH client. A second computer
can use exactly the same workflow:

```text
Ubuntu computer A (client)
  -> LAN or Tailscale
  -> SSH
  -> Ubuntu computer B (server)
  -> tmux
  -> Shell / Git / Python / build / agent
```

The roles are separate:

- The client is the computer in front of the user. It runs `ssh` or VS Code.
- The server is the computer that owns the project files and runs the work.
- Tailscale or a LAN provides reachability; it does not provide a terminal.
- OpenSSH provides the terminal connection; tmux keeps the work alive.

## Target computer setup

On Ubuntu computer B, run the repository check:

```bash
./scripts/check-environment.sh
```

The target needs an SSH server and tmux. The machine owner must install and
enable them according to the local policy. This repository does not copy keys,
change passwords, or configure personal authentication automatically.

For a Tailscale connection, authenticate both computers interactively and
check the target's Tailscale name or address:

```bash
tailscale status
tailscale ip -4
```

From Ubuntu computer A, connect with a real user and target name:

```bash
ssh YOUR_USERNAME@YOUR_UBUNTU_HOST
```

The target name can be a LAN hostname, a Tailscale hostname, or a Tailscale IP.
Do not put a real address or username in this repository.

## Persistence test

After SSH authentication has been configured on both computers, run this from
Ubuntu computer A:

```bash
./scripts/test-ubuntu-to-ubuntu.sh YOUR_USERNAME@YOUR_UBUNTU_HOST
```

The test starts a uniquely named tmux session on computer B, ends the first
SSH process, reconnects, checks the session, and captures the task output. It
removes only the temporary session it created. It does not install packages or
modify SSH configuration.

This test proves the important boundary:

```text
SSH connection ends
  -> tmux session remains on computer B
  -> task output is available after a new SSH connection
```

It does not prove that every application survives a failure. A command may
still exit, fail, or wait for input; tmux preserves the terminal workspace.

## Normal work

Create a named workspace on computer B:

```bash
ssh YOUR_USERNAME@YOUR_UBUNTU_HOST
tmux new -s project-work
cd YOUR_PROJECT_PATH
```

Run ordinary commands or an agent inside tmux. Detach, let the SSH connection
end, and return later:

```bash
tmux detach-client
exit

ssh YOUR_USERNAME@YOUR_UBUNTU_HOST
tmux ls
tmux attach -t project-work
```

This is the same machine-layer workflow as the Android path. Only the SSH
client changes from a phone terminal to another computer.

## Current validation status

The local development machine is Ubuntu 24.04.4 LTS with an active SSH server,
tmux 3.4, and Tailscale. A second Ubuntu node is not currently available in
the test environment, so the cross-computer test is documented and scripted but
must not be reported as passed until it is run against another Ubuntu machine.
