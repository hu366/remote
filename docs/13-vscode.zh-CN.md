# VS Code 远程开发

电脑连接电脑时，推荐使用 VS Code 的 **Remote - SSH**。VS Code 图形界面运行在控制端电脑，项目文件、终端命令、扩展和调试进程运行在 Ubuntu 被控端。

```text
电脑 A 上的 VS Code
  -> Remote - SSH
  -> SSH / Tailscale
  -> 电脑 B 上的 VS Code Server
  -> 电脑 B 上的项目文件和开发工具
```

这不是远程桌面：它不会传输电脑 B 的整个桌面画面，而是让本地 VS Code 连接到远程开发环境。

## Remote - SSH 配置

1. 在 Ubuntu 电脑 A 安装 Visual Studio Code。
2. 安装 Microsoft 发布的 `Remote - SSH` 扩展。
3. 先确认普通 SSH 可以使用：

   ```bash
   ssh YOUR_USERNAME@YOUR_UBUNTU_HOST
   ```

4. 在 VS Code 命令面板选择 `Remote-SSH: Connect to Host...`。
5. 输入 `YOUR_USERNAME@YOUR_UBUNTU_HOST`，或者在控制端用户的 `~/.ssh/config` 中添加：

   ```sshconfig
   Host remote-ubuntu
       HostName YOUR_UBUNTU_HOST
       User YOUR_USERNAME
   ```

6. 连接后打开电脑 B 上的 `YOUR_PROJECT_PATH`。

第一次连接时，VS Code 会在远程用户目录中安装或启动 VS Code Server。需要项目环境的扩展应安装到远程扩展主机。编译器、Python、ROS2、Git 和其他命令使用的是电脑 B 的环境，不是电脑 A 的环境。

## VS Code 和 tmux 一起使用

VS Code 集成终端适合短命令，但它不能替代 tmux。长期任务在 VS Code 终端中进入同一个 tmux 会话：

```bash
tmux ls
tmux attach -t project-work
```

职责可以这样理解：

```text
VS Code Remote - SSH -> 编辑、跳转、调试、远程扩展
tmux                -> 长时间 Shell、编译、日志和 CLI Agent
SSH                  -> 传输和认证
Tailscale/局域网     -> 网络可达
```

即使 VS Code 关闭，tmux 仍可以保持编译或 Agent；SSH 或 VS Code 连接中断后，重新连接并重新 attach 即可。

## Remote Tunnels

VS Code 还支持 Remote Tunnels。可以在被控端运行 `code tunnel`，然后从已登录的 VS Code 客户端或浏览器连接。它使用 VS Code Tunnel 服务，不要求控制端直接访问被控端 SSH 端口。

Remote Tunnels 适合入站 SSH 不可用的场景，但它和本项目的 Tailscale + SSH 是两种不同传输方式，需要 Microsoft 账号交互认证。不要把 Tunnel 测试结果当成 SSH + tmux 测试结果；如果两种方式都要支持，应分别验证。

## 需要完整桌面时

Remote - SSH 适合源码和开发工具。如果需要控制电脑 B 上的任意 GUI 应用，应另外使用远程桌面方案。这属于另一层能力，不是当前 Ubuntu 终端工作流的一部分。

## 当前验证状态

VS Code 方案已经写入设计，但当前环境没有第二台 Ubuntu 电脑，尚未完成 Remote - SSH 双机实测。第一轮应验证普通 SSH、Remote - SSH 打开远程目录、远程终端命令，以及关闭 VS Code 窗口后 tmux 任务是否继续运行。
