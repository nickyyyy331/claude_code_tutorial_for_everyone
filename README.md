# Claude Code 完整教程 - 适合所有人

这是一个面向初学者的 Claude Code 安装和使用完整解决方案。
Claude Code 可以作为日常工具用于应用开发和网页生成。

## 📚 文档目录

### 1. [WSL 环境下 Claude Code 配置指南](./WSL_CLAUDE_SETUP_GUIDE.md)
**适合对象**：Windows 用户在 WSL/Ubuntu 中安装 Claude Code

**解决问题**：
- ✅ WSL 无法使用 Windows VPN 代理
- ✅ 连接 Anthropic 服务失败（ERR_BAD_REQUEST）
- ✅ 区域限制问题

**包含内容**：
- 配置 WSL 使用 Windows 代理的完整命令
- 使用 API Key 的配置方法（推荐）
- 防火墙设置
- 常见问题排查

### 2. [网页版 vs 本地版对比](./WEB_VS_LOCAL_CLAUDE_CODE.md)
**适合对象**：想了解选择哪种方式使用 Claude Code

**对比内容**：
- 网页版 (claude.ai/code) vs 本地版 (CLI) 详细对比
- 使用场景建议
- 工作流程说明
- GitHub 集成说明

**推荐结论**：
- 对于中国大陆 Windows 用户，推荐使用网页版
- 网页版代码自动保存到 GitHub，可以在本地 clone 后运行

## 🚀 快速开始

### 方案 A：网页版（推荐给 Windows 用户）

1. 确保 Windows 已连接 VPN（日本/美国等支持地区）
2. 访问 https://claude.ai/code
3. 连接 GitHub 账号
4. 开始编码，代码自动保存到 GitHub
5. 在本地克隆仓库运行：
   ```powershell
   git clone https://github.com/你的用户名/项目名.git
   cd 项目名
   # 根据项目类型运行
   ```

### 方案 B：本地版（WSL/Linux）

1. 查看 [WSL_CLAUDE_SETUP_GUIDE.md](./WSL_CLAUDE_SETUP_GUIDE.md)
2. 配置 WSL 代理或 API Key
3. 在终端运行 `claude-code`

## 🔧 常见问题

### Q1: 我应该选择网页版还是本地版？
参考 [WEB_VS_LOCAL_CLAUDE_CODE.md](./WEB_VS_LOCAL_CLAUDE_CODE.md) 中的详细对比。

### Q2: WSL 无法连接 Anthropic 怎么办？
参考 [WSL_CLAUDE_SETUP_GUIDE.md](./WSL_CLAUDE_SETUP_GUIDE.md) 中的解决方案。

### Q3: 网页版的代码能在本地运行吗？
可以！通过 `git clone` 到本地即可运行。

## 📝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个教程！

## 📄 许可证

MIT License
