# Remote Terminal

The workflow is the same whether the client is a phone or another computer:

```text
Phone or computer -> Tailscale/LAN -> SSH -> Ubuntu shell -> tmux -> command or agent
```

It supports ordinary terminal work, not only AI agents:

```bash
pwd
ls
git status
python3 YOUR_SCRIPT.py
cmake --build build
ros2 topic list
```

Long-running work belongs inside tmux:

```bash
tmux new -s project-work
YOUR_COMMAND
```

Detach without stopping the command:

```bash
tmux detach-client
```

Reattach later:

```bash
tmux attach -t project-work
```

To inspect output without sending arrow keys to a foreground program, use a
second SSH connection:

```bash
tmux capture-pane -p -t project-work:0 -S -100 | less -R
```

SSH ending does not terminate a detached tmux session. The application itself
can still exit, fail, or request input; tmux preserves the workspace, not the
success of every application.
