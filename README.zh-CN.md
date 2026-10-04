# Remote Agent

Remote Agent 是一套可迁移的远程终端工作流，用于通过手机或另一台电脑远程控制自己电脑上的终端、命令行工具和 AI Agent。

它不是新的 AI Agent，也不是只服务于 Codex 或 Claude 的工具。它提供远程访问和持久化终端基础，让 Shell、Git、Python、ROS2、编译工具、Codex、Claude 以及其他 CLI 程序都可以运行在同一套工作流中。

```text
手机或电脑 -> Tailscale/局域网 -> SSH -> tmux -> Shell / 开发工具 / AI Agent
```

## 当前范围

第一阶段实际支持 Ubuntu 24.04.4 LTS。手机或另一台电脑都可以作为控制端，目标 Ubuntu 电脑负责保存项目和运行任务。机器级环境和项目级开发环境分开管理，方便将工作流迁移到另一台 Ubuntu 电脑。

当前仓库提供：

- Ubuntu 环境检查脚本
- 幂等的 tmux 安装脚本
- SSH、Tailscale、Android、tmux 和 CLI Agent 文档
- Ubuntu 电脑到电脑的连接测试脚本和文档
- VS Code Remote - SSH / Remote Tunnels 说明
- Windows 后端路线图

## Ubuntu 快速开始

运行环境检查：

```bash
./scripts/check-environment.sh
```

如果 tmux 尚未安装：

```bash
./scripts/install-tmux.sh
```

创建一个持久化终端工作区：

```bash
tmux new -s work
```

在 tmux 中运行命令，然后使用 `Ctrl-b`，再按 `d` 分离。之后可以重新进入：

```bash
tmux ls
tmux attach -t work
```

在手机终端中如果无法使用 Ctrl 快捷键，也可以在 tmux 内执行：

```bash
tmux detach-client
```

安装脚本不会配置个人认证、SSH 密钥、Tailscale 或第三方 Agent 账号。

## Ubuntu 电脑到电脑部署

使用一台 Ubuntu 作为被控端电脑 B，另一台 Ubuntu 作为控制端电脑 A。项目文件和实际命令运行在电脑 B。

在电脑 B 上部署仓库和基础环境：

```bash
git clone git@github.com:YOUR_GITHUB_OWNER/remote-agent.git "$HOME/remote-agent"
cd "$HOME/remote-agent"
./scripts/check-environment.sh
./scripts/install-tmux.sh
```

如果检查结果显示 SSH Server 缺失，在电脑 B 上安装并启用：

```bash
sudo apt update
sudo apt install openssh-server
sudo systemctl enable --now ssh
```

如果两台电脑不在同一个局域网，在两台电脑上分别登录 Tailscale。不要把 Tailscale Auth Key 写入仓库。在电脑 A 上先测试普通 SSH：

```bash
ssh YOUR_USERNAME@YOUR_UBUNTU_HOST
```

然后在电脑 A 的仓库副本中执行断开重连测试：

```bash
./scripts/test-ubuntu-to-ubuntu.sh YOUR_USERNAME@YOUR_UBUNTU_HOST
```

正常工作时，在电脑 B 上创建持久化会话：

```bash
ssh YOUR_USERNAME@YOUR_UBUNTU_HOST
tmux new -s project-work
cd YOUR_PROJECT_PATH
```

使用 `Ctrl-b`，再按 `d` 分离；也可以执行 `tmux detach-client`。之后重新连接：

```bash
ssh YOUR_USERNAME@YOUR_UBUNTU_HOST
tmux attach -t project-work
```

仓库不会自动配置密码、SSH 密钥、防火墙、Tailscale 账号或第三方 Agent 账号。

## 在电脑 A 使用 VS Code

在电脑 A 安装 VS Code 和 Microsoft 的 `Remote - SSH` 扩展。先确认上面的 SSH 命令可以连接，再选择 `Remote-SSH: Connect to Host...`，输入 `YOUR_USERNAME@YOUR_UBUNTU_HOST`，然后打开电脑 B 上的项目目录。

VS Code 界面运行在电脑 A，源码、编译器、Python、ROS2、扩展和调试进程运行在电脑 B。长期编译、日志和 CLI Agent 在 VS Code 终端中进入 tmux。VS Code Remote Tunnels 可以作为 SSH 不可用时的替代传输，但它与 Tailscale + SSH + tmux 是不同工作流。

## 远程终端使用场景

同一个远程终端可以用于：

- 查看日志和长期运行的进程
- 运行脚本和 Python 程序
- 执行 Git 操作
- 执行 CMake 或其他构建任务
- 执行 ROS2 命令
- 执行安全的 Shell 管理命令
- 运行 Codex、Claude 等 CLI Agent

手机或另一台电脑连接示例：

```bash
ssh YOUR_USERNAME@YOUR_TAILSCALE_HOST
tmux attach -t work
```

四个组件的职责如下：

| 组件 | 职责 |
| --- | --- |
| Tailscale | 提供手机和电脑之间的网络连接 |
| SSH | 提供远程终端连接 |
| tmux | 保存长期存在的终端工作区 |
| Shell / Agent | 在终端中实际运行的应用 |

Tailscale 负责网络，SSH 负责远程终端，tmux 负责终端生命周期。tmux 不负责网络，Tailscale 也不负责保存终端程序。

## Ubuntu 电脑连接电脑

电脑 A 作为控制端，电脑 B 作为被控端时，工作流是：

```text
Ubuntu A -> Tailscale 或局域网 -> SSH -> Ubuntu B -> tmux -> 命令或 Agent
```

在电脑 A 上执行双机持久化测试：

```bash
./scripts/test-ubuntu-to-ubuntu.sh YOUR_USERNAME@YOUR_UBUNTU_HOST
```

测试会结束第一条 SSH 连接，再重新连接并检查电脑 B 上的 tmux 任务是否仍有输出。详细步骤见 [Ubuntu 电脑连接 Ubuntu 电脑](docs/12-computer-to-computer.zh-CN.md)。

当前环境没有第二台 Ubuntu 电脑，因此该路径尚未标记为实测通过。

## VS Code 远程开发

电脑之间开发时，推荐在控制端安装 VS Code 和 `Remote - SSH` 扩展，通过 SSH 打开被控端目录。编辑器界面在控制端，代码、编译器、Python、ROS2、扩展和调试进程在被控端。

长期编译、日志和 CLI Agent 仍然放在被控端的 tmux 中；VS Code 负责编辑和调试，不替代 tmux。VS Code Remote Tunnels 是 SSH 之外的另一种连接方式，适合入站 SSH 不可用的情况，需要单独认证和验证。详见 [VS Code 远程开发](docs/13-vscode.zh-CN.md)。

## 在 tmux 中运行 AI Agent

Codex、Claude 和其他 CLI Agent 都是远程终端中的应用，不是 Remote Agent 的基础设施。

Codex 示例：

```bash
export PATH="$HOME/.local/bin:$PATH"
tmux new -s codex
cd YOUR_PROJECT_PATH
codex
```

Claude 示例：

```bash
export PATH="$HOME/.local/bin:$PATH"
tmux new -s claude
cd YOUR_PROJECT_PATH
claude
```

某些安装方式会把 CLI 程序放在 `$HOME/.local/bin`。非交互式 SSH Shell 可能不会自动加载这个目录，因此需要手动加入 `PATH`。

tmux 恢复的是原来的终端工作区；例如 `codex resume` 恢复的是 Agent 自己的历史会话。二者不是同一件事。

## Android 使用方式

Android 端需要：

1. 安装并登录 Tailscale，使用与 Ubuntu 相同的账号。
2. 安装 Termux 或其他支持 OpenSSH 的终端应用。
3. 在终端中安装 SSH 客户端并连接 Ubuntu。

Termux 示例：

```bash
pkg update
pkg install openssh
ssh YOUR_USERNAME@YOUR_TAILSCALE_HOST
```

连接后进入 tmux：

```bash
tmux ls
tmux attach -t work
```

如果手机键盘没有 Ctrl 键，可以使用 Termux 的额外按键栏，或者直接执行：

```bash
tmux detach-client
```

不要单独输入 `d`。单独的 `d` 会被 Shell 当作普通命令，而不是 tmux 的分离快捷键。

## 断线后的行为

在 tmux 中运行的任务不会因为 SSH 连接结束而自动停止：

```text
手机断网
  -> SSH 断开
  -> tmux 继续存在
  -> 任务继续运行
  -> 手机恢复网络
  -> 重新 SSH
  -> tmux attach
  -> 继续工作
```

tmux 保存的是终端工作区，并不能保证应用本身一定不会退出、失败或等待输入。

## 当前验证状态

以下内容已于 2026-09-13 在第一台 Ubuntu 电脑上实际验证：

| 项目 | 状态 |
| --- | --- |
| Ubuntu 24.04.4 LTS | 已通过 |
| tmux 3.4 会话持久化 | 已通过 |
| SSH 公钥登录 | 已通过 |
| SSH 断开后 tmux 继续运行 | 已通过 |
| Tailscale 地址连接 SSH | 已通过 |
| Android SSH 连接 | 已手动通过 |
| Android 断网后重新连接 | 已手动通过 |
| 断线后 CLI Agent 继续交互 | 已手动通过 |
| Ubuntu 到 Ubuntu 的 SSH + tmux | 尚未在第二台 Ubuntu 电脑上验证 |
| VS Code Remote - SSH | 尚未在第二台 Ubuntu 电脑上验证 |
| 第二台 Ubuntu 电脑迁移 | 尚未验证 |

Android 和 Agent 测试是手动测试，不是自动化设备测试。仓库不保存任何账号凭证、私钥或设备认证配置。

## 项目文件

- [英文 README](README.md)
- [项目概览](docs/01-overview.md)
- [远程终端](docs/02-remote-terminal.md)
- [tmux 指南](docs/03-tmux.md)
- [SSH 指南](docs/04-ssh.md)
- [Tailscale 指南](docs/05-tailscale.md)
- [Android 工作流](docs/06-android.md)
- [AI Agent](docs/07-ai-agents.md)
- [可迁移性](docs/08-portability.md)
- [Windows 路线图](docs/09-windows-roadmap.md)
- [故障排查](docs/10-troubleshooting.md)
- [个人命令速查](docs/11-command-cheatsheet.zh-CN.md)
- [Ubuntu 电脑连接 Ubuntu 电脑](docs/12-computer-to-computer.zh-CN.md)
- [VS Code 远程开发](docs/13-vscode.zh-CN.md)

## 安全边界

Remote Agent 不建议把 SSH 直接暴露到公网，也不会自动：

- 修改用户密码
- 删除 SSH 密钥
- 修改 Tailscale ACL
- 上传凭证
- 推送到 GitHub

不要把以下内容提交到仓库：

- 密码
- SSH 私钥
- API Token
- Tailscale Auth Key
- Codex 或 Claude 凭证
- 真实 IP、真实主机名和私人路径
