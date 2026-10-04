# Android

The first Android workflow uses a Tailscale app plus a terminal application
that can run OpenSSH. Termux is the preferred open terminal option.

Install Android packages from official or trusted distribution channels. Do
not mix Termux packages from unrelated sources or use random APK mirrors.

After installing and signing into Tailscale with the same account as Ubuntu,
open the terminal app and install its OpenSSH package. In Termux:

```bash
pkg update
pkg install openssh
ssh YOUR_USERNAME@YOUR_TAILSCALE_HOST
```

Then attach to a persistent workspace:

```bash
tmux ls
tmux attach -t work
```

If the Android terminal has no visible Ctrl key, use its extra-key row or the
terminal's documented Ctrl-key gesture. Detaching can also be done inside
tmux without a prefix shortcut:

```bash
tmux detach-client
```

The first phone connected through Tailscale and SSH, attached to tmux, lost
network connectivity, reconnected, and observed the task continuing. An
interactive CLI agent was also resumed in the same tmux terminal. This was a
manual test, not an automated Android test.
