# WSL 环境下 Claude Code 配置指南

## 问题分析

你遇到的问题是：
1. **WSL 无法访问 Windows 的 VPN 代理** - WSL 中的 localhost 不会自动使用 Windows 的代理
2. **Claude Code 连接失败** - ERR_BAD_REQUEST 错误

## 解决方案 1：配置 WSL 使用 Windows 代理

### 步骤 1：获取 Windows 主机 IP

在 WSL Ubuntu 终端中运行：

```bash
# 获取 Windows 主机的 IP 地址
export WINDOWS_HOST=$(ip route show | grep -i default | awk '{ print $3}')
echo "Windows Host IP: $WINDOWS_HOST"
```

### 步骤 2：设置代理环境变量

假设你的 Windows 代理端口是 7890（常见的 Clash/V2Ray 端口），运行：

```bash
# 设置 HTTP 和 HTTPS 代理
export http_proxy="http://${WINDOWS_HOST}:7890"
export https_proxy="http://${WINDOWS_HOST}:7890"
export HTTP_PROXY="http://${WINDOWS_HOST}:7890"
export HTTPS_PROXY="http://${WINDOWS_HOST}:7890"

# 验证代理设置
echo "HTTP Proxy: $http_proxy"
echo "HTTPS Proxy: $https_proxy"
```

**注意**：如果你的代理端口不是 7890，请修改为实际端口号（常见端口：10808, 10809, 7890, 1080）

### 步骤 3：测试网络连接

```bash
# 测试是否能访问 Google（验证代理是否工作）
curl -I https://www.google.com

# 测试是否能访问 Anthropic API
curl -I https://api.anthropic.com
```

### 步骤 4：永久保存代理配置

将代理配置添加到 ~/.bashrc 文件：

```bash
# 编辑 bashrc 文件
cat >> ~/.bashrc << 'EOF'

# WSL 代理配置
export WINDOWS_HOST=$(ip route show | grep -i default | awk '{ print $3}')
export http_proxy="http://${WINDOWS_HOST}:7890"
export https_proxy="http://${WINDOWS_HOST}:7890"
export HTTP_PROXY="http://${WINDOWS_HOST}:7890"
export HTTPS_PROXY="http://${WINDOWS_HOST}:7890"
EOF

# 重新加载配置
source ~/.bashrc
```

### 步骤 5：启动 Claude Code

```bash
# 现在尝试启动 Claude Code
claude-code
```

---

## 解决方案 2：使用 API Key（推荐）

这个方法更稳定，不依赖网页登录。

### 步骤 1：获取 API Key

1. 在 Windows 浏览器中访问：https://console.anthropic.com/settings/keys
2. 点击 "Create Key" 创建新的 API key
3. 复制生成的 API key（格式：sk-ant-xxx）

### 步骤 2：配置 Claude Code 使用 API Key

在 WSL Ubuntu 终端中运行：

```bash
# 设置 API Key 环境变量
export ANTHROPIC_API_KEY="sk-ant-你的API密钥"

# 永久保存到 bashrc
echo 'export ANTHROPIC_API_KEY="sk-ant-你的API密钥"' >> ~/.bashrc

# 重新加载配置
source ~/.bashrc
```

### 步骤 3：验证配置

```bash
# 检查 API key 是否设置成功
echo $ANTHROPIC_API_KEY

# 启动 Claude Code
claude-code
```

---

## 解决方案 3：检查 Windows 防火墙设置

如果以上方法仍无法解决，可能是防火墙阻止了 WSL 访问：

### 在 Windows PowerShell（管理员权限）中运行：

```powershell
# 允许 WSL 通过防火墙
New-NetFirewallRule -DisplayName "WSL" -Direction Inbound -InterfaceAlias "vEthernet (WSL)" -Action Allow
```

---

## 常见问题排查

### 1. 找不到正确的代理端口

在 Windows 上检查你的代理软件端口号：
- Clash: 通常是 7890 或 7891
- V2Ray: 通常是 10808 或 10809
- SSR: 通常是 1080

### 2. 测试代理是否在 Windows 上正常工作

在 Windows PowerShell 中：

```powershell
# 测试代理
curl -x http://127.0.0.1:7890 https://www.google.com
```

### 3. WSL 网络重置

如果遇到网络问题，在 Windows PowerShell（管理员）中：

```powershell
# 重启 WSL
wsl --shutdown
# 然后重新打开 WSL
```

---

## 快速命令汇总

```bash
# 一键配置（修改端口号为你的实际端口）
export WINDOWS_HOST=$(ip route show | grep -i default | awk '{ print $3}')
export http_proxy="http://${WINDOWS_HOST}:7890"
export https_proxy="http://${WINDOWS_HOST}:7890"

# 测试连接
curl -I https://api.anthropic.com

# 启动 Claude Code
claude-code
```

---

## 推荐方案

**最简单的解决方法**：使用解决方案 2（API Key 方式），因为：
- 不依赖网页登录
- 不受区域限制影响
- 配置一次永久有效
- 更稳定可靠
