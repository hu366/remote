# Windows Roadmap

Windows support is a future backend, not part of the first Ubuntu
implementation.

The shared contract should remain:

```text
remote connection
remote terminal
persistent session
remote commands
CLI applications and agents
```

Possible Windows components include Windows OpenSSH Server, Windows Terminal,
PowerShell, Tailscale, and a Windows-compatible session manager.

Windows does not need to use tmux internally. The Ubuntu backend can use SSH
and tmux while a Windows backend uses SSH and a Windows-native session
manager. The first Windows milestone should document and test that backend
boundary before adding automation.
