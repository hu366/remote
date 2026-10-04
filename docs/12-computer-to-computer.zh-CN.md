# Ubuntu 电脑连接 Ubuntu 电脑

Remote Agent 不要求客户端必须是手机。另一台 Ubuntu 电脑可以使用完全相同的工作流：

```text
Ubuntu 电脑 A（控制端）
  -> 局域网或 Tailscale
  -> SSH
  -> Ubuntu 电脑 B（被控端）
  -> tmux
  -> Shell / Git / Python / 编译 / Agent
```

这里要分清角色：

- 控制端是用户当前操作的电脑，运行 `ssh` 或 VS Code。
- 被控端保存项目文件并实际运行命令、编译器和 Agent。
- Tailscale 或局域网只负责网络可达，不提供终端。
- OpenSSH 提供终端连接，tmux 保持终端工作区和长期任务。

## 被控端准备

在 Ubuntu 电脑 B 上运行：

```bash
./scripts/check-environment.sh
```

被控端需要 SSH Server 和 tmux。安装、启用和用户认证由机器所有者按自己的安全策略完成；仓库不会自动复制密钥、修改密码或处理个人认证。

如果使用 Tailscale，在两台电脑上分别登录并查看被控端地址：

```bash
tailscale status
tailscale ip -4
```

从 Ubuntu 电脑 A 连接：

```bash
ssh YOUR_USERNAME@YOUR_UBUNTU_HOST
```

`YOUR_UBUNTU_HOST` 可以是局域网主机名、Tailscale 主机名或 Tailscale IP。仓库中不要写入真实用户名、地址或机器名。

## 双机持久化测试

两台电脑完成 SSH 认证后，在 Ubuntu 电脑 A 执行：

```bash
./scripts/test-ubuntu-to-ubuntu.sh YOUR_USERNAME@YOUR_UBUNTU_HOST
```

脚本会在电脑 B 创建一个唯一命名的 tmux 测试会话，结束第一条 SSH 连接，等待后重新 SSH，检查会话并读取任务输出。最后只删除它自己创建的临时会话，不安装软件，也不修改 SSH 配置。

它验证的核心原理是：

```text
SSH 连接结束
  -> 电脑 B 上的 tmux 会话仍然存在
  -> 新 SSH 连接可以重新看到任务输出
```

这不能保证每个应用都不会失败。命令本身仍可能退出、报错或等待输入；tmux 保存的是终端工作区。

## 正常工作方式

在电脑 B 创建工作区：

```bash
ssh YOUR_USERNAME@YOUR_UBUNTU_HOST
tmux new -s project-work
cd YOUR_PROJECT_PATH
```

在 tmux 中运行普通命令或 Agent。需要离开时分离并退出 SSH，之后重新连接：

```bash
tmux detach-client
exit

ssh YOUR_USERNAME@YOUR_UBUNTU_HOST
tmux ls
tmux attach -t project-work
```

这和 Android 路径使用的是同一套机器层；变化的只是 SSH 客户端从手机终端变成了另一台电脑。

## 当前验证状态

当前开发环境是 Ubuntu 24.04.4 LTS，SSH Server 已启用，tmux 3.4 和 Tailscale 已安装。当前测试环境没有第二台 Ubuntu 节点，因此双机测试脚本已经准备好，但不能把 Ubuntu-to-Ubuntu 连接标记为已通过，必须在另一台 Ubuntu 电脑上实际运行后再记录结果。
