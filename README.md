# Claude Code 完全教程（适合所有人）

本仓库提供 Claude Code 的完整安装和使用指南，特别针对初学者和 WSL 用户。

## 📚 目录

- [快速开始](#快速开始)
- [WSL 用户特别说明](#wsl-用户特别说明)
- [文件说明](#文件说明)
- [使用场景](#使用场景)

---

## 🚀 快速开始

### 系统要求

- Node.js >= 18.x
- npm 或 yarn
- Anthropic API Key

### 基础安装

```bash
# 安装 Claude Code
npm install -g @anthropic-ai/claude-code

# 设置 API Key
export ANTHROPIC_API_KEY="your-api-key-here"

# 启动 Claude Code
claude
```

---

## 🐧 WSL 用户特别说明

### 常见问题

如果在 WSL 环境下遇到以下错误：

```
InvalidArgumentError: Invalid URL protocol: the URL must start with `http:` or `https:`
```

或看到警告：

```
wsl: 检测到 localhost 代理配置，但未镜像到 WSL。NAT 模式下的 WSL 不支持 localhost 代理。
```

### 快速修复

```bash
# 1. 运行自动修复脚本
chmod +x fix-wsl-claude-proxy.sh
./fix-wsl-claude-proxy.sh

# 2. 加载环境配置
source ~/.claude-code-env

# 3. 启动 Claude Code
claude
```

### 详细文档

完整的故障排除指南请查看：[WSL-Claude-Code-故障排除指南.md](./WSL-Claude-Code-故障排除指南.md)

---

## 📁 文件说明

### 1. `fix-wsl-claude-proxy.sh`

WSL 环境下 Claude Code 的自动修复脚本。

**功能：**
- 诊断代理配置问题
- 清除冲突的环境变量
- 设置正确的网络配置
- 创建持久化配置文件
- 测试 API 连接

**使用方法：**
```bash
./fix-wsl-claude-proxy.sh
```

### 2. `WSL-Claude-Code-故障排除指南.md`

完整的故障排除文档，包含：
- 问题原因分析
- 详细修复步骤
- 常见问题 FAQ
- 进阶配置方法
- 调试技巧

### 3. `下载资源链接.txt`

相关资源下载链接。

---

## 💡 使用场景

Claude Code 可以作为日常工具用于：

### 1. 应用程序开发
- 快速生成代码框架
- 代码审查和优化
- Bug 修复建议
- 重构代码

### 2. Web 页面生成
- HTML/CSS/JavaScript 开发
- React/Vue/Angular 组件
- 响应式设计
- 前端优化

### 3. 自动化任务
- 脚本编写
- 数据处理
- API 集成
- 测试用例生成

### 4. 学习和探索
- 代码解释
- 最佳实践建议
- 技术栈选择
- 架构设计

---

## 🔧 配置说明

### API Key 设置

#### 方法 1：环境变量（推荐）

```bash
# 临时设置（当前会话）
export ANTHROPIC_API_KEY="sk-ant-api03-xxxxx..."

# 持久化设置（添加到 ~/.bashrc 或 ~/.zshrc）
echo 'export ANTHROPIC_API_KEY="sk-ant-api03-xxxxx..."' >> ~/.bashrc
source ~/.bashrc
```

#### 方法 2：配置文件

```bash
# 使用修复脚本创建的配置文件
source ~/.claude-code-env
```

### 代理配置（WSL 用户）

如果需要使用代理，请确保：

1. **使用正确的代理地址格式**
   ```bash
   # ✅ 正确：使用 Windows 主机 IP
   export http_proxy="http://172.x.x.x:7890"

   # ❌ 错误：使用 localhost（WSL NAT 模式下不可用）
   export http_proxy="http://localhost:7890"
   ```

2. **绕过 Anthropic API 的代理**
   ```bash
   export NO_PROXY="api.anthropic.com,localhost,127.0.0.1"
   ```

---

## 📖 教程系列

### 基础教程
1. ✅ [安装和配置](./WSL-Claude-Code-故障排除指南.md#详细修复步骤)
2. 🔄 基本使用和命令（开发中）
3. 🔄 项目集成（开发中）

### 进阶教程
1. 🔄 自定义配置（开发中）
2. 🔄 Hook 和插件（开发中）
3. 🔄 最佳实践（开发中）

---

## 🐛 故障排除

### 常见问题

#### 1. 无法连接到 API

**检查清单：**
- [ ] API Key 是否正确设置
- [ ] 网络连接是否正常
- [ ] 代理配置是否正确
- [ ] 防火墙是否阻止连接

**解决方法：**
```bash
# 测试 API 连接
curl -i https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01"
```

#### 2. 权限错误

**解决方法：**
```bash
# 修复 npm 全局包权限
sudo chown -R $(whoami) $(npm root -g)
```

#### 3. Node.js 版本过低

**解决方法：**
```bash
# 安装 Node.js LTS
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 获取帮助

- 📖 查看[完整故障排除指南](./WSL-Claude-Code-故障排除指南.md)
- 🐛 [提交 Issue](https://github.com/anthropics/claude-code/issues)
- 📚 [官方文档](https://docs.anthropic.com)

---

## 🤝 贡献

欢迎贡献！如果你有：
- 新的使用技巧
- 故障排除经验
- 教程改进建议
- Bug 修复

请提交 Pull Request 或创建 Issue。

---

## 📝 许可

本教程遵循 MIT 许可证。

---

## 🙏 致谢

- [Anthropic](https://www.anthropic.com/) - Claude Code 开发团队
- 所有贡献者和用户反馈

---

**最后更新：** 2025-12-31
**文档版本：** 1.0
