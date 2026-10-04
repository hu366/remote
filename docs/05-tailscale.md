# Tailscale

Tailscale provides the private network path between the phone and Ubuntu. SSH
remains the terminal protocol, and tmux remains the persistent workspace.

After installing Tailscale, verify the daemon and authenticate interactively:

```bash
tailscale version
systemctl status tailscaled --no-pager
sudo tailscale up
tailscale status
tailscale ip -4
```

Never commit an auth key or device credential to this repository.

```text
Android Tailscale app -> Ubuntu Tailscale node -> SSH -> tmux
```

The first Ubuntu machine was tested using its Tailscale address for SSH and a
detached tmux task. The task remained visible after reconnecting. Tailscale
reachability does not guarantee SSH authentication, so troubleshoot those
layers separately.
