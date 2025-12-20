#!/bin/bash

# CNB云原生开发环境启动脚本 - 精简版
# 仅启动工作空间，不检查状态
# 使用方法: ./start_cnb_simple.sh <组织名> <仓库名> <访问令牌> [分支]

ORG_NAME="$1"
REPO_NAME="$2"
ACCESS_TOKEN="$3"
BRANCH="${4:-main}"

if [ -z "$ORG_NAME" ] || [ -z "$REPO_NAME" ] || [ -z "$ACCESS_TOKEN" ]; then
    echo "使用方法: $0 <组织名> <仓库名> <访问令牌> [分支]"
    echo "示例: $0 shrinft demominecraftserverhost 2XS12cbwbcIiczGTNUV4p4DkqmA"
    exit 1
fi

echo "🚀 启动CNB云原生开发环境..."

# 启动工作空间
response=$(curl -s -X POST \
  -H "Authorization: token $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"branch\":\"$BRANCH\"}" \
  "https://api.cnb.cool/$ORG_NAME/$REPO_NAME/-/workspace/start")

# 显示完整响应
echo "响应: $response"

# 提取关键信息
sn=$(echo "$response" | grep -o '"sn":"[^"]*"' | head -1 | cut -d'"' -f4)
url=$(echo "$response" | grep -o '"url":"[^"]*"' | head -1 | cut -d'"' -f4)
build_log_url=$(echo "$response" | grep -o '"buildLogUrl":"[^"]*"' | head -1 | cut -d'"' -f4)

echo ""
echo "✅ 工作空间启动请求已提交!"
echo "🔢 SN: $sn"
echo "🌐 加载页面: $url"
echo "📊 构建日志: $build_log_url"

echo ""
echo "💡 提示:"
echo "1. 请访问加载页面查看工作空间状态: $url"
echo "2. 构建完成后，页面会自动跳转到工作空间"
echo "3. 您也可以通过构建日志查看进度: $build_log_url"