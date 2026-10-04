# SSH

SSH provides the remote terminal connection from a phone or another computer.
It does not keep terminal programs alive after disconnection; tmux handles that
responsibility.

On Ubuntu, check the server with:

```bash
systemctl status ssh --no-pager
systemctl is-active ssh.socket
systemctl is-enabled ssh.socket
ss -ltn | grep ':22'
```

Install the server only when needed:

```bash
sudo apt update
sudo apt install openssh-server
```

Connect from the client computer or phone with a target-specific username and
host:

```bash
ssh YOUR_USERNAME@YOUR_TAILSCALE_HOST
```

Then attach to the persistent workspace:

```bash
tmux ls
tmux attach -t work
```

This first machine was tested by starting a continuous date command in tmux,
ending SSH, reconnecting, and observing that output continued.

This project does not generate, copy, publish, or delete private keys. Keep
local SSH permissions restrictive:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```
