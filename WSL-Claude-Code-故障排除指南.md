# WSL 环境下 Claude Code 故障排除完全指南

## 📋 目录

1. [问题概述](#问题概述)
2. [错误原因分析](#错误原因分析)
3. [快速修复方案](#快速修复方案)
4. [详细修复步骤](#详细修复步骤)
5. [常见问题 FAQ](#常见问题-faq)
6. [进阶配置](#进阶配置)

---

## 问题概述

### 典型错误信息

```
InvalidArgumentError]: Invalid URL protocol: the URL must start with `http:` or `https:`.
```

### WSL 警告信息

```
wsl: 检测到 localhost 代理配置，但未镜像到 WSL。NAT 模式下的 WSL 不支持 localhost 代理。
```

### 问题表现

- 在 Windows 环境下 Claude Code 正常工作
- 在 WSL (Ubuntu/Debian) 环境下启动 `claude` 命令失败
- 无法使用 VPN（尤其是日本节点）导致连接问题

---

## 错误原因分析

### 根本原因

1. **代理配置冲突**
   - Windows 系统设置了代理（如 localhost:7890）
   - WSL 继承了 Windows 的代理环境变量
   - WSL NAT 模式无法正确访问 Windows 的 localhost 代理

2. **环境变量传递问题**
   ```bash
   # 可能存在的问题环境变量
   http_proxy=http://localhost:7890
   https_proxy=http://localhost:7890
   ```

3. **Claude Code 的网络请求机制**
   - Claude Code 使用 `undici` 库进行 HTTP 请求
   - 该库严格验证 URL 格式
   - 当检测到无效的代理 URL 时会抛出错误

### 技术细节

```javascript
// Claude Code 内部错误触发点
// file:///usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js:186
// 解析代理 URL 时发现格式无效
```

---

## 快速修复方案

### 方案 A：使用自动修复脚本（推荐）

```bash
# 1. 下载并运行修复脚本
cd ~/claude_code_tutorial_for_everyone
chmod +x fix-wsl-claude-proxy.sh
./fix-wsl-claude-proxy.sh

# 2. 加载环境配置
source ~/.claude-code-env

# 3. 启动 Claude Code
claude
```

### 方案 B：手动快速修复

```bash
# 1. 清除代理
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY

# 2. 设置绕过代理
export NO_PROXY="api.anthropic.com,localhost,127.0.0.1"

# 3. 设置 API Key
export ANTHROPIC_API_KEY="your-api-key-here"

# 4. 启动 Claude Code
npx --yes @anthropic-ai/claude-code
```

---

## 详细修复步骤

### 步骤 1：诊断当前环境

```bash
# 检查当前代理设置
env | grep -i proxy

# 检查 WSL 版本
wsl --version

# 检查 Node.js 和 npm
node --version
npm --version

# 检查 Claude Code 安装
npm list -g @anthropic-ai/claude-code
```

**预期输出分析：**
- 如果看到 `http_proxy=http://localhost:xxxx`，说明存在代理冲突
- Node.js 版本应 >= 18.x
- 如果 Claude Code 未安装，需要先安装

### 步骤 2：清理代理环境变量

```bash
# 临时清除（当前会话有效）
unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
unset all_proxy
unset ALL_PROXY
unset ftp_proxy
unset FTP_PROXY

# 验证清除结果
env | grep -i proxy
# 应该没有任何输出
```

### 步骤 3：配置持久化环境

创建 `~/.claude-code-env` 文件：

```bash
cat > ~/.claude-code-env << 'EOF'
# Claude Code 环境配置

# 清除所有代理
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
unset all_proxy ALL_PROXY ftp_proxy FTP_PROXY

# 设置绕过代理（确保 Anthropic API 不走代理）
export NO_PROXY="api.anthropic.com,localhost,127.0.0.1,::1"
export no_proxy="api.anthropic.com,localhost,127.0.0.1,::1"

# 设置 API Key（替换为你的实际密钥）
export ANTHROPIC_API_KEY="sk-ant-api03-xxxxx..."
EOF
```

### 步骤 4：添加到 Shell 启动文件

```bash
# 对于 Bash 用户
echo '' >> ~/.bashrc
echo '# Claude Code 环境配置' >> ~/.bashrc
echo 'if [ -f ~/.claude-code-env ]; then' >> ~/.bashrc
echo '    source ~/.claude-code-env' >> ~/.bashrc
echo 'fi' >> ~/.bashrc

# 对于 Zsh 用户
echo '' >> ~/.zshrc
echo '# Claude Code 环境配置' >> ~/.zshrc
echo 'if [ -f ~/.claude-code-env ]; then' >> ~/.zshrc
echo '    source ~/.claude-code-env' >> ~/.zshrc
echo 'fi' >> ~/.zshrc
```

### 步骤 5：测试配置

```bash
# 重新加载配置
source ~/.claude-code-env

# 验证环境变量
echo "代理设置:"
env | grep -i proxy || echo "  ✓ 无代理配置"

echo ""
echo "API Key:"
echo "  ${ANTHROPIC_API_KEY:0:20}..."

echo ""
echo "NO_PROXY:"
echo "  $NO_PROXY"
```

### 步骤 6：测试 API 连接

```bash
# 使用 curl 测试 API 连接
curl -i https://api.anthropic.com/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"claude-3-5-sonnet-20241022","max_tokens":1024,"messages":[{"role":"user","content":"Hello"}]}'
```

**预期结果：**
- HTTP 200 OK 表示 API Key 有效且可以连接
- HTTP 400/401 表示 API Key 问题
- 连接超时表示网络问题

### 步骤 7：启动 Claude Code

```bash
# 方法 1：使用全局命令（如果已安装）
claude

# 方法 2：使用 npx（推荐，无需全局安装）
npx --yes @anthropic-ai/claude-code

# 方法 3：使用完整路径
/usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js
```

---

## 常见问题 FAQ

### Q1: 为什么在 Windows 下能运行，WSL 下不能？

**A:** Windows 和 WSL 是两个独立的网络栈：
- Windows 代理使用 `localhost` 或 `127.0.0.1`
- 在 WSL NAT 模式下，这些地址指向 WSL 自身，而非 Windows
- 解决方案：直接绕过代理，让 WSL 直接访问 Anthropic API

### Q2: 如何在保留 Windows 代理的同时使用 Claude Code？

**A:** 使用 `NO_PROXY` 环境变量：

```bash
# 只让 Anthropic API 绕过代理
export NO_PROXY="api.anthropic.com"
export no_proxy="api.anthropic.com"
```

如果需要使用代理访问其他服务，可以设置 Windows 主机 IP：

```bash
# 获取 Windows 主机 IP
WINDOWS_IP=$(ip route | grep default | awk '{print $3}')

# 设置代理为 Windows IP（而非 localhost）
export http_proxy="http://$WINDOWS_IP:7890"
export https_proxy="http://$WINDOWS_IP:7890"

# 但仍然绕过 Anthropic API
export NO_PROXY="api.anthropic.com"
```

### Q3: 修复后仍然报错怎么办？

**排查步骤：**

1. **检查环境变量是否生效**
   ```bash
   env | grep -i proxy
   echo $ANTHROPIC_API_KEY
   ```

2. **检查 WSL 网络连接**
   ```bash
   # 测试基本网络
   ping -c 3 google.com

   # 测试 HTTPS 连接
   curl -I https://www.anthropic.com
   ```

3. **检查 Node.js 和 npm 权限**
   ```bash
   # 检查全局 npm 包位置
   npm root -g

   # 检查权限
   ls -la $(npm root -g)
   ```

4. **重新安装 Claude Code**
   ```bash
   # 卸载
   sudo npm uninstall -g @anthropic-ai/claude-code

   # 清除缓存
   npm cache clean --force

   # 重新安装
   sudo npm install -g @anthropic-ai/claude-code
   ```

### Q4: API Key 正确但仍无法连接？

**可能原因：**

1. **网络防火墙**
   ```bash
   # 检查是否能访问 Anthropic API
   curl -v https://api.anthropic.com
   ```

2. **DNS 问题**
   ```bash
   # 检查 DNS 解析
   nslookup api.anthropic.com

   # 尝试使用其他 DNS
   sudo nano /etc/resolv.conf
   # 添加：nameserver 8.8.8.8
   ```

3. **API Key 格式问题**
   - 确保 API Key 以 `sk-ant-api03-` 开头
   - 没有多余的空格或换行符
   ```bash
   # 检查 API Key 长度和格式
   echo -n "$ANTHROPIC_API_KEY" | wc -c
   # 应该是固定长度（约 108 字符）
   ```

### Q5: 如何在每次启动 WSL 时自动加载配置？

**A:** 配置已添加到 `~/.bashrc` 或 `~/.zshrc`，每次启动自动加载。

如果需要手动验证：
```bash
# 检查配置是否在启动文件中
grep "claude-code-env" ~/.bashrc

# 手动测试加载
source ~/.bashrc
env | grep -i anthropic
```

### Q6: 能否使用 VPN 来访问 Claude API？

**A:** 可以，但需要注意：

1. **VPN 在 WSL 中正常工作**
   - 使用 TUN/TAP 模式的 VPN（如 OpenVPN）
   - 或在 Windows 上设置 VPN，WSL 会继承连接

2. **检查 VPN 连接**
   ```bash
   # 检查外网 IP
   curl ifconfig.me

   # 检查到 Anthropic API 的路由
   traceroute api.anthropic.com
   ```

3. **VPN 代理设置**
   - 如果 VPN 使用代理，确保代理 URL 格式正确
   - 使用 `http://IP:PORT` 而非 `http://localhost:PORT`

### Q7: 如何切换不同的 API Key？

**A:**

```bash
# 方法 1：临时切换
export ANTHROPIC_API_KEY="new-api-key"
claude

# 方法 2：使用别名
# 添加到 ~/.bashrc
alias claude-work='ANTHROPIC_API_KEY="work-key" claude'
alias claude-personal='ANTHROPIC_API_KEY="personal-key" claude'

# 使用
claude-work
claude-personal

# 方法 3：使用配置文件
cat > ~/.claude-keys << 'EOF'
WORK_KEY="sk-ant-api03-xxxxx"
PERSONAL_KEY="sk-ant-api03-yyyyy"
EOF

# 切换时加载
export ANTHROPIC_API_KEY=$(grep WORK_KEY ~/.claude-keys | cut -d'=' -f2 | tr -d '"')
```

---

## 进阶配置

### WSL 2 网络模式配置

WSL 2 有两种网络模式：

#### 1. NAT 模式（默认）

**特点：**
- WSL 有独立的 IP 地址
- 无法直接访问 Windows 的 `localhost` 服务
- 适合大多数用户

**配置（无需额外设置）**

#### 2. 镜像模式（Mirror Mode）

**特点：**
- WSL 和 Windows 共享网络栈
- 可以访问 Windows 的 `localhost` 服务
- 需要 Windows 11 22H2 或更高版本

**配置方法：**

创建 `%USERPROFILE%\.wslconfig` 文件（在 Windows 中）：

```ini
[wsl2]
networkingMode=mirrored
dnsTunneling=true
firewall=true
autoProxy=true
```

重启 WSL：
```powershell
wsl --shutdown
wsl
```

**注意：** 镜像模式可能解决部分代理问题，但仍建议使用绕过代理的方式。

### 使用 .wslconfig 配置代理

在 Windows 中创建 `C:\Users\<YourUsername>\.wslconfig`：

```ini
[wsl2]
# 禁用自动代理检测
autoProxy=false

# 设置内存限制（可选）
memory=4GB
processors=2

# 网络模式
networkingMode=nat
```

### 为 Claude Code 创建启动脚本

创建 `/usr/local/bin/claude-safe` 脚本：

```bash
#!/bin/bash
# Claude Code 安全启动脚本

# 加载配置
if [ -f ~/.claude-code-env ]; then
    source ~/.claude-code-env
fi

# 验证 API Key
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "错误：ANTHROPIC_API_KEY 未设置"
    echo "请在 ~/.claude-code-env 中配置 API Key"
    exit 1
fi

# 清除代理
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY

# 设置绕过代理
export NO_PROXY="api.anthropic.com,localhost,127.0.0.1"

# 启动 Claude Code
npx --yes @anthropic-ai/claude-code "$@"
```

使脚本可执行：
```bash
chmod +x /usr/local/bin/claude-safe
```

使用：
```bash
claude-safe
```

### 配置 systemd 服务（可选）

如果需要 Claude Code 作为后台服务运行（不常用，仅供参考）：

创建 `~/.config/systemd/user/claude-code.service`：

```ini
[Unit]
Description=Claude Code Service
After=network.target

[Service]
Type=simple
EnvironmentFile=%h/.claude-code-env
ExecStart=/usr/bin/npx --yes @anthropic-ai/claude-code
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
```

启用服务：
```bash
systemctl --user enable claude-code
systemctl --user start claude-code
```

### 调试和日志

启用详细日志：

```bash
# 设置 DEBUG 环境变量
export DEBUG=*

# 或只显示 Claude Code 相关日志
export DEBUG=claude*

# 启动 Claude Code
claude
```

查看 Node.js 网络调试信息：

```bash
# 启用 Node.js 网络调试
export NODE_DEBUG=http,https,net,tls

# 启动 Claude Code
claude
```

### 网络抓包分析

使用 `tcpdump` 查看网络请求：

```bash
# 安装 tcpdump
sudo apt-get install tcpdump

# 抓包（在另一个终端）
sudo tcpdump -i any -n host api.anthropic.com -w claude-traffic.pcap

# 启动 Claude Code（在原终端）
claude

# 分析抓包文件
tcpdump -r claude-traffic.pcap -A
```

---

## 总结

### 核心解决方案

1. **清除代理环境变量**
   ```bash
   unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY
   ```

2. **设置绕过代理**
   ```bash
   export NO_PROXY="api.anthropic.com,localhost,127.0.0.1"
   ```

3. **设置 API Key**
   ```bash
   export ANTHROPIC_API_KEY="your-api-key"
   ```

4. **启动 Claude Code**
   ```bash
   npx --yes @anthropic-ai/claude-code
   ```

### 推荐工作流程

```bash
# 1. 运行自动修复脚本
./fix-wsl-claude-proxy.sh

# 2. 重启 WSL（如果需要）
# 在 PowerShell 中：wsl --shutdown

# 3. 重新打开 WSL 并启动 Claude Code
claude
```

### 获取帮助

如果仍然遇到问题：

1. 查看 GitHub Issues: https://github.com/anthropics/claude-code/issues
2. 检查官方文档: https://docs.anthropic.com
3. 提供详细错误日志和环境信息

---

**文档版本：** 1.0
**最后更新：** 2025-12-31
**适用版本：** Claude Code 2.x, WSL 2
