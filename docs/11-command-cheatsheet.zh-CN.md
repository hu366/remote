# Remote Agent 命令速查

这是一份日常使用清单，适合保存到手机上查看。

请将以下占位符替换成自己的值：

```text
YOUR_USERNAME       Ubuntu 用户名，可用 whoami 查看
YOUR_TAILSCALE_HOST Ubuntu 的 Tailscale IP 或主机名
YOUR_PROJECT_PATH   项目目录
```

## 手机连接 Ubuntu

在 Termux 中执行：

```bash
ssh YOUR_USERNAME@YOUR_TAILSCALE_HOST
```

退出 SSH：

```bash
exit
```

## tmux 基本命令

```bash
tmux new -s work
tmux ls
tmux attach -t work
tmux detach-client
tmux kill-session -t work
```

`tmux kill-session` 会终止该 session 中的程序，请确认任务不再需要后再执行。

## 手机上管理多个终端

### 多个独立 session

每个 session 可以代表一个项目或任务：

```bash
tmux new -s project-a
```

进入第一个 session 后，如果要先离开但保留它运行：

```bash
tmux detach-client
```

回到普通 SSH Shell 后创建其他 session。使用 `-d` 可以创建后不进入：

```bash
tmux new-session -d -s ros
tmux new-session -d -s codex
```

查看所有 session：

```bash
tmux ls
```

进入指定 session：

```bash
tmux attach -t project-a
tmux attach -t ros
tmux attach -t codex
```

推荐用不同名字区分工作：

```text
project-a  普通开发
ros        ROS2
codex      Codex
claude     Claude
```

### 同一个 session 中创建多个 window

```bash
tmux new-window -n logs
tmux new-window -n shell
tmux list-windows
tmux select-window -t logs
```

### 同一个 window 中分割多个 pane

水平分割：

```bash
tmux split-window -h
```

上下分割：

```bash
tmux split-window -v
```

查看当前 pane：

```bash
tmux list-panes
```

手机上最简单、最稳定的方式通常是使用多个独立 session。

标准快捷键是：

```text
Ctrl-b，然后松开，再按 d
```

手机 Ctrl 键不好用时，直接使用 `tmux detach-client`。不要单独输入 `d`，否则会被 Shell 当作命令。

## tmux 鼠标滚动和触摸操作

临时开启当前 tmux server 的鼠标支持：

```bash
tmux set-option -g mouse on
```

检查是否已开启：

```bash
tmux show-option -g mouse
```

开启后可以尝试在终端区域上下滑动。如果 Termux 支持触摸滚动，tmux 会进入历史输出查看状态，不会把滑动直接当成前台程序的方向键。

永久开启：

```bash
mkdir -p ~/.config/tmux
printf 'set -g mouse on\n' >> ~/.config/tmux/tmux.conf
```

如果已有配置文件，不要重复追加同一行；也可以手动编辑 `~/.config/tmux/tmux.conf`。

如果触摸滚动仍然无效，使用：

```bash
tmux copy-mode
```

或者从第二个 SSH 连接查看：

```bash
tmux capture-pane -p -t SESSION_NAME:0 -S -100 | less -R
```

## 推荐日常流程

```bash
ssh YOUR_USERNAME@YOUR_TAILSCALE_HOST
tmux ls
tmux attach -t work
cd YOUR_PROJECT_PATH
```

运行普通命令：

```bash
pwd
ls
git status
python3 YOUR_SCRIPT.py
cmake --build build
```

离开时：

```bash
tmux detach-client
exit
```

## 查看运行中的输出

程序运行时，不要直接按手机上方向键，否则可能出现：

```text
^[[A
```

最稳妥的方法是打开第二个 Termux 标签页，再次 SSH 登录后执行：

```bash
tmux capture-pane -p -t work:0 -S -100 | less -R
```

在 `less` 中，使用上下键滚动、`Space` 翻页、`q` 退出。

也可以执行：

```bash
tmux copy-mode
```

查看完成后按 `q` 或 `Esc`。

## Codex 和 Claude

SSH 后先补充 CLI 路径：

```bash
export PATH="$HOME/.local/bin:$PATH"
```

启动 Codex：

```bash
tmux new -s codex
cd YOUR_PROJECT_PATH
codex
```

启动 Claude：

```bash
tmux new -s claude
cd YOUR_PROJECT_PATH
claude
```

如果提示找不到命令：

```bash
command -v codex
command -v claude
ls -l "$HOME/.local/bin/codex" "$HOME/.local/bin/claude"
export PATH="$HOME/.local/bin:$PATH"
```

## 断线后恢复

手机恢复网络后：

```bash
ssh YOUR_USERNAME@YOUR_TAILSCALE_HOST
tmux ls
tmux attach -t work
```

Codex 或 Claude 分别使用：

```bash
tmux attach -t codex
tmux attach -t claude
```

tmux 恢复终端工作区；Agent 自己的 `resume` 命令恢复 Agent 历史会话，二者不是一回事。

## Ubuntu 电脑检查

```bash
whoami
lsb_release -a
tailscale status
tailscale ip -4
systemctl is-active ssh.socket
```

检查项目环境：

```bash
cd YOUR_PROJECT_PATH
./scripts/check-environment.sh
```

## 常见错误

### 把 `tmux` 拼成 `tumx`

正确命令是：

```bash
tmux
```

### `sessions should be nested with care`

说明已经在 tmux 中。检查：

```bash
echo "$TMUX"
```

有输出表示在 tmux 中。退出显示但保留任务：

```bash
tmux detach-client
```

### session 不存在

```bash
tmux ls
tmux new -s work
```

### SSH 无法连接

在 Ubuntu 检查：

```bash
tailscale status
systemctl is-active ssh.socket
ss -ltn | grep ':22'
```

## 安全提醒

不要把密码、SSH 私钥、Tailscale Auth Key、Codex/Claude 凭证或真实设备认证文件写入仓库。不要把 SSH 端口直接暴露到公网，优先使用 Tailscale。
