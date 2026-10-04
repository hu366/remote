# Overview

Remote Agent is a remote terminal workflow. It makes a local Ubuntu computer
usable from a phone or another computer while keeping long-running terminal
work alive across network interruptions.

```text
Tailscale       network connection between devices
SSH             remote terminal connection
tmux            persistent terminal workspace
Shell / Agent   applications inside that workspace
```

Machine-layer components are Ubuntu, SSH, Tailscale, tmux, and a client
terminal or VS Code. Project-layer components are Git repositories, Python,
ROS2, build toolchains, and CLI applications. Only the machine layer is
required for the basic remote terminal workflow.

Ubuntu 24.04.4 LTS, tmux, SSH, Tailscale, Android SSH, and one interactive CLI
agent were validated on the first machine. The Ubuntu-to-Ubuntu test is
implemented but a second Ubuntu computer has not been tested.
