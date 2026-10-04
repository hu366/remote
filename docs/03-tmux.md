# tmux

tmux runs on the target computer. It is not a remote access tool.

## Concepts

- **Session**: a persistent workspace such as `work` or `ros`.
- **Window**: a tab inside a session.
- **Pane**: a split terminal inside a window.
- **Attach**: connect the current terminal to an existing session.
- **Detach**: leave the session running while disconnecting the current view.
- **Kill**: stop a session and its processes.

## Common commands

```bash
tmux new -s SESSION_NAME
tmux ls
tmux attach -t SESSION_NAME
tmux detach-client
tmux kill-session -t SESSION_NAME
```

Inside tmux, the default prefix is `Ctrl-b`. Press `Ctrl-b`, release both keys,
then press `d` to detach. On a phone terminal without a usable Ctrl key,
`tmux detach-client` performs the same operation without a prefix shortcut.

To inspect scrollback:

```bash
tmux copy-mode
```

Use the terminal scroll controls in copy mode, then press `q` or `Esc`. The
example configuration in `config/tmux.conf.example` is not installed
automatically and never overwrites an existing user configuration.
