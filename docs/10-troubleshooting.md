# Troubleshooting

## SSH works but tmux is missing

On Ubuntu:

```bash
./scripts/install-tmux.sh
```

## `sessions should be nested with care`

You are already inside tmux. Check:

```bash
echo "$TMUX"
```

Detach without a keyboard prefix:

```bash
tmux detach-client
```

## Arrow keys print `^[[A`

The terminal is sending the escape sequence for the Up key to the foreground
program. Do not keep pressing it. Use another SSH connection and inspect the
pane:

```bash
tmux capture-pane -p -t SESSION_NAME:0 -S -100 | less -R
```

Or enter tmux copy mode with `tmux copy-mode` when it is safe to type that
command.

## `codex` or `claude` is not found over SSH

Check whether the binary is under the local user bin directory:

```bash
ls -l "$HOME/.local/bin/codex" "$HOME/.local/bin/claude"
export PATH="$HOME/.local/bin:$PATH"
```

The first machine required this explicit PATH export for non-interactive SSH
commands.

## Tailscale is connected but SSH fails

Test each layer separately:

```bash
tailscale status
tailscale ip -4
ssh YOUR_USERNAME@YOUR_TAILSCALE_HOST
```

Tailscale reachability does not guarantee SSH authentication. Check the SSH
server, username, and authorized public key independently.
