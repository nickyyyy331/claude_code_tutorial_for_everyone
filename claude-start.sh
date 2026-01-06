#!/bin/bash
# Claude Code 启动脚本

# 清除代理
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY

# 设置绕过代理
export NO_PROXY="api.anthropic.com,localhost,127.0.0.1"
export no_proxy="api.anthropic.com,localhost,127.0.0.1"

# 设置 API Key（替换为你的实际 API Key）
# 如果已经在环境变量中设置，则使用环境变量的值
if [ -z "$ANTHROPIC_API_KEY" ]; then
    export ANTHROPIC_API_KEY='your-actual-api-key-here'
    echo "⚠ 警告：请在脚本中设置你的 API Key"
    echo "   编辑此文件并替换 'your-actual-api-key-here'"
    exit 1
fi

echo "✓ Claude Code 环境已配置"
echo "✓ 代理已清除"
echo "✓ API Key: ${ANTHROPIC_API_KEY:0:20}..."
echo ""
echo "正在启动 Claude Code..."
echo ""

# 启动 Claude Code（使用正确的包名）
npx --yes @anthropic-ai/claude-code
