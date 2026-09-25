#!/bin/bash
# whwithsxh 一键部署：推送代码到 GitHub
# 用法：先确保仓库 Chrisbetheking/whwithsxh 已在 GitHub 上创建（空仓库），然后运行 ./deploy.sh
set -e
cd "$(dirname "$0")"

echo "→ 当前修改状态："
git status --short || true

echo "→ 推送到 GitHub…"
git push -u origin main

echo ""
echo "✅ 代码已推送！"
echo ""
echo "还需最后一步（只需做一次）："
echo "  打开 https://github.com/Chrisbetheking/whwithsxh/settings/pages"
echo "  → Source 选 'Deploy from a branch'"
echo "  → Branch 选 'main'，目录选 '/ (root)' → Save"
echo ""
echo "  等 1-2 分钟后访问：https://chrisbetheking.github.io/whwithsxh/"
