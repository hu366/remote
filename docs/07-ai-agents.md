# AI Agents

Codex, Claude, and other CLI agents are applications inside the remote
terminal workflow. They are not the networking or persistence layer.

```bash
export PATH="$HOME/.local/bin:$PATH"
tmux new -s codex
cd YOUR_PROJECT_PATH
codex
```

For Claude, use a separate session named `claude` and run `claude` in it.

The PATH export matters when a CLI was installed under `$HOME/.local/bin` and
the SSH shell does not load the user's interactive profile.

tmux restores the terminal workspace. An agent-specific command such as
`codex resume` restores an agent's historical session. One does not replace
the other.

Authentication and account setup remain manual user actions. The repository
does not store agent credentials.
