# VS Code Remote Development

For computer-to-computer development, the recommended VS Code path is
**Remote - SSH**. VS Code runs its graphical interface on the client computer,
while the project files, terminal commands, extensions, and debugging process
run on the Ubuntu target.

```text
VS Code on computer A
  -> Remote - SSH
  -> SSH / Tailscale
  -> VS Code Server on Ubuntu computer B
  -> project files and tools on computer B
```

This is different from remote desktop. The pixels of the whole target desktop
are not streamed to the client; VS Code provides a local editor connected to a
remote development environment.

## Remote - SSH setup

1. Install Visual Studio Code on Ubuntu computer A.
2. Install the `Remote - SSH` extension published by Microsoft.
3. Make sure ordinary SSH works first:

   ```bash
   ssh YOUR_USERNAME@YOUR_UBUNTU_HOST
   ```

4. In VS Code, open the Command Palette and choose `Remote-SSH: Connect to
   Host...`.
5. Enter `YOUR_USERNAME@YOUR_UBUNTU_HOST`, or add a host alias to the client
   user's `~/.ssh/config`:

   ```sshconfig
   Host remote-ubuntu
       HostName YOUR_UBUNTU_HOST
       User YOUR_USERNAME
   ```

6. After connection, open `YOUR_PROJECT_PATH` on the remote host.

The first connection installs or starts VS Code Server in the remote user's
home directory. Extensions that need the project environment should be
installed in the remote extension host. Compilers, Python, ROS2, Git, and
other commands are taken from Ubuntu computer B, not from the client.

## tmux and VS Code together

VS Code's integrated terminal is useful for short commands, but it is not a
replacement for tmux. For long-running jobs, use a terminal inside VS Code to
attach to the same persistent session:

```bash
tmux ls
tmux attach -t project-work
```

The recommended division is:

```text
VS Code Remote - SSH -> editing, navigation, debugging, remote extensions
tmux                -> long-running shells, builds, logs, and CLI agents
SSH                  -> transport and authentication
Tailscale/LAN        -> network reachability
```

If VS Code closes, tmux can keep a build or agent alive. If the SSH transport
is interrupted, reconnect VS Code and reattach to tmux as needed.

## Remote Tunnels

VS Code also supports Remote Tunnels. On the target computer, a user can run
`code tunnel` and then connect from a signed-in VS Code client or the browser.
This uses the VS Code tunnel service instead of requiring the client to reach
the target's SSH port.

Remote Tunnels can help when inbound SSH is not possible, but they are a
separate transport from this project's Tailscale + SSH design. They require
interactive Microsoft authentication and a supported VS Code installation.
Do not treat a tunnel as a replacement for the project's SSH/tmux persistence
test; validate both paths separately if both are needed.

## When full remote desktop is required

Remote - SSH is appropriate for source code and development tools. If the
requirement is to control arbitrary GUI applications on computer B, use a
separate remote-desktop solution. That is a different layer and is outside the
current Ubuntu terminal workflow.

## Validation status

The VS Code design is documented but has not been validated against a second
Ubuntu computer in the current environment. First pass testing should verify
ordinary SSH, Remote - SSH opening a remote folder, a remote terminal command,
and a long-running tmux task after the VS Code window is closed.
