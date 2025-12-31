#!/bin/bash

#===============================================================================
# Claude Code WSL 代理配置修复脚本
#
# 问题描述：
# - WSL 环境下运行 claude 命令时出现 "Invalid URL protocol" 错误
# - 错误原因：WSL 检测到 localhost 代理但无法正确处理
#
# 解决方案：
# 1. 清除所有代理环境变量
# 2. 配置绕过代理设置
# 3. 设置 ANTHROPIC_API_KEY
# 4. 启动 Claude Code
#===============================================================================

set -e  # 遇到错误立即退出

echo "=========================================="
echo "  Claude Code WSL 代理配置修复工具"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# API Key（请替换为你的实际 API Key）
# 从环境变量读取，如果未设置则提示用户
ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}"

#===============================================================================
# 步骤 1: 诊断当前代理配置
#===============================================================================
echo "步骤 1: 诊断当前代理配置"
echo "----------------------------------------"

echo "检查代理相关环境变量："
env | grep -i proxy || echo "  (未发现代理环境变量)"
echo ""

#===============================================================================
# 步骤 2: 清除所有代理设置
#===============================================================================
echo "步骤 2: 清除所有代理设置"
echo "----------------------------------------"

# 清除所有可能的代理环境变量
unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
unset ftp_proxy
unset FTP_PROXY
unset all_proxy
unset ALL_PROXY
unset no_proxy
unset NO_PROXY

echo -e "${GREEN}✓${NC} 已清除所有代理环境变量"
echo ""

#===============================================================================
# 步骤 3: 设置绕过代理配置
#===============================================================================
echo "步骤 3: 设置绕过代理配置"
echo "----------------------------------------"

# 确保 Anthropic API 不通过代理访问
export NO_PROXY="api.anthropic.com,localhost,127.0.0.1"
export no_proxy="api.anthropic.com,localhost,127.0.0.1"

echo -e "${GREEN}✓${NC} NO_PROXY = $NO_PROXY"
echo ""

#===============================================================================
# 步骤 4: 设置 ANTHROPIC_API_KEY
#===============================================================================
echo "步骤 4: 设置 ANTHROPIC_API_KEY"
echo "----------------------------------------"

if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo -e "${RED}✗${NC} 错误：ANTHROPIC_API_KEY 未设置"
    echo ""
    echo "请按以下方式设置："
    echo "  export ANTHROPIC_API_KEY='your-api-key-here'"
    echo "  然后重新运行此脚本"
    exit 1
fi

export ANTHROPIC_API_KEY
echo -e "${GREEN}✓${NC} API Key 已设置: ${ANTHROPIC_API_KEY:0:20}..."
echo ""

#===============================================================================
# 步骤 5: 验证 Claude Code 安装
#===============================================================================
echo "步骤 5: 验证 Claude Code 安装"
echo "----------------------------------------"

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗${NC} Node.js 未安装"
    echo "请先安装 Node.js："
    echo "  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -"
    echo "  sudo apt-get install -y nodejs"
    exit 1
fi
echo -e "${GREEN}✓${NC} Node.js 版本: $(node --version)"

# 检查 npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}✗${NC} npm 未安装"
    exit 1
fi
echo -e "${GREEN}✓${NC} npm 版本: $(npm --version)"

# 检查 Claude Code
CLAUDE_PATH=$(npm root -g)/@anthropic-ai/claude-code
if [ ! -d "$CLAUDE_PATH" ]; then
    echo -e "${YELLOW}!${NC} Claude Code 未安装，正在安装..."
    sudo npm install -g @anthropic-ai/claude-code
    echo -e "${GREEN}✓${NC} Claude Code 安装完成"
else
    echo -e "${GREEN}✓${NC} Claude Code 已安装在: $CLAUDE_PATH"
fi
echo ""

#===============================================================================
# 步骤 6: 创建启动配置文件
#===============================================================================
echo "步骤 6: 创建启动配置文件"
echo "----------------------------------------"

# 创建 ~/.claude-code-env 配置文件
cat > ~/.claude-code-env << 'EOF'
# Claude Code 环境配置
# 此文件用于修复 WSL 代理问题

# 清除代理设置
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
unset ftp_proxy FTP_PROXY all_proxy ALL_PROXY

# 设置绕过代理
export NO_PROXY="api.anthropic.com,localhost,127.0.0.1"
export no_proxy="api.anthropic.com,localhost,127.0.0.1"

# 设置 API Key（请替换为你的实际 API Key）
export ANTHROPIC_API_KEY="your-api-key-here"
EOF

echo -e "${GREEN}✓${NC} 已创建 ~/.claude-code-env 配置文件"
echo ""

#===============================================================================
# 步骤 7: 添加到 shell 配置
#===============================================================================
echo "步骤 7: 添加到 shell 配置"
echo "----------------------------------------"

# 检测用户的 shell
SHELL_RC=""
if [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
fi

if [ -n "$SHELL_RC" ] && [ -f "$SHELL_RC" ]; then
    # 检查是否已经添加
    if ! grep -q "source ~/.claude-code-env" "$SHELL_RC"; then
        echo "" >> "$SHELL_RC"
        echo "# Claude Code 环境配置（自动添加）" >> "$SHELL_RC"
        echo "if [ -f ~/.claude-code-env ]; then" >> "$SHELL_RC"
        echo "    source ~/.claude-code-env" >> "$SHELL_RC"
        echo "fi" >> "$SHELL_RC"
        echo -e "${GREEN}✓${NC} 已添加到 $SHELL_RC"
    else
        echo -e "${YELLOW}!${NC} $SHELL_RC 中已存在配置"
    fi
else
    echo -e "${YELLOW}!${NC} 未检测到 shell 配置文件"
fi
echo ""

#===============================================================================
# 步骤 8: 测试 API 连接
#===============================================================================
echo "步骤 8: 测试 API 连接"
echo "----------------------------------------"

# 测试 API 连接（使用 curl）
if command -v curl &> /dev/null; then
    echo "测试连接到 api.anthropic.com..."
    if curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        https://api.anthropic.com/v1/messages > /tmp/api_test 2>&1; then

        HTTP_CODE=$(cat /tmp/api_test)
        if [ "$HTTP_CODE" = "400" ] || [ "$HTTP_CODE" = "200" ]; then
            echo -e "${GREEN}✓${NC} API 连接成功 (HTTP $HTTP_CODE)"
        else
            echo -e "${YELLOW}!${NC} API 返回 HTTP $HTTP_CODE（可能需要检查 API Key）"
        fi
        rm -f /tmp/api_test
    else
        echo -e "${RED}✗${NC} 无法连接到 API（请检查网络连接）"
    fi
else
    echo -e "${YELLOW}!${NC} curl 未安装，跳过连接测试"
fi
echo ""

#===============================================================================
# 步骤 9: 启动 Claude Code
#===============================================================================
echo "=========================================="
echo "  修复完成！"
echo "=========================================="
echo ""
echo "现在你可以使用以下命令启动 Claude Code："
echo ""
echo -e "  ${GREEN}source ~/.claude-code-env${NC}"
echo -e "  ${GREEN}claude${NC}"
echo ""
echo "或者直接运行："
echo ""
echo -e "  ${GREEN}npx --yes @anthropic-ai/claude-code${NC}"
echo ""
echo "如果仍然遇到问题，请尝试："
echo ""
echo "1. 重新启动 WSL："
echo "   在 Windows PowerShell 中运行: wsl --shutdown"
echo "   然后重新打开 WSL"
echo ""
echo "2. 手动检查代理设置："
echo "   env | grep -i proxy"
echo ""
echo "3. 查看详细错误日志"
echo ""
echo "=========================================="
