# Portability

The target migration is from one Ubuntu computer to another without carrying
machine credentials or personal paths in the repository.

```text
New Ubuntu computer
  -> clone repository
  -> run check-environment.sh
  -> install missing base packages
  -> configure SSH manually
  -> install and authenticate Tailscale manually
  -> install/configure tmux
  -> install and authenticate CLI agents manually
  -> test a project session
```

Use `$HOME`, `~`, `YOUR_USERNAME`, `YOUR_TAILSCALE_HOST`, and
`YOUR_PROJECT_PATH` in commands and documentation. Do not copy private keys,
passwords, tokens, cookies, or real device authentication files into the
repository.

Migration to a second Ubuntu computer is designed but not yet validated.

The same target can be controlled from a phone or another computer. The client
only needs a compatible SSH client; the target keeps the Ubuntu, SSH, Tailscale
and tmux machine layer. VS Code Remote - SSH is an optional client workflow
described in `docs/13-vscode.md`.
