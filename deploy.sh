#!/bin/bash
# 一键更新作品集网页（首次部署后日常更新用）
# 用法：放到项目根目录，改下面 PROJECT_DIR 和 REPO_NAME 两处，然后运行 ./deploy.sh
set -e

# ===== 项目配置（按需修改） =====
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"   # 脚本所在目录即项目根
REPO_NAME="REPO_NAME_PLACEHOLDER"               # GitHub 仓库名
# =================================

# 命令行走本机代理（按实际端口调整）
export https_proxy=http://127.0.0.1:7890
export http_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7890

PUB="$PROJECT_DIR/_publish"
if [ ! -d "$PUB/.git" ]; then
  echo "错误：$PUB 不是 git 仓库。请先按 references/deploy-github-pages.md 完成首次部署。"
  exit 1
fi

echo "==> 同步 index.html 与 assets/ 到 $PUB ..."
mkdir -p "$PUB/assets"
rsync -a --delete "$PROJECT_DIR/index.html" "$PUB/index.html"
rsync -a --delete "$PROJECT_DIR/assets/img/"   "$PUB/assets/img/"
rsync -a --delete "$PROJECT_DIR/assets/video/" "$PUB/assets/video/"

cd "$PUB"
git add -A

if git diff --cached --quiet; then
  echo "没有变更需要发布。"
  exit 0
fi

git commit -m "更新作品集 $(date '+%Y-%m-%d %H:%M')"
echo "==> 推送到 GitHub..."
git push origin main

GH_USER=$(gh api user -q .login)
echo ""
echo "✅ 已完成。GitHub Pages 约 1-2 分钟后自动更新："
echo "   https://${GH_USER}.github.io/${REPO_NAME}/"
