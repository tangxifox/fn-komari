#!/usr/bin/env bash
set -euo pipefail

mirror=""
arches=()
out=""

for arg in "$@"; do
  case "$arg" in
    mirror=*)
      mirror="${arg#mirror=}"
      ;;
    x86)
      arches=(amd64)
      out="x86"
      ;;
    arm)
      arches=(arm64)
      out="arm"
      ;;
    all)
      arches=(amd64 arm64)
      out="all"
      ;;
    *)
      echo "用法: $0 <x86|arm|all> [mirror=https://xxx]"
      exit 1
      ;;
  esac
done

[[ ${#arches[@]} -eq 0 ]] && { echo "缺少架构参数"; exit 1; }

# 创建目录
mkdir -p app/bin data

# 获取 GitHub 最新版本
version=$(curl -sL https://api.github.com/repos/komari-monitor/komari/releases/latest \
  | grep '"tag_name"' \
  | cut -d'"' -f4 \
  | sed 's/^v//')

echo "远程版本: $version"

# 更新 manifest 版本
sed -i "s|^version=.*|version=$version|" manifest

# 强制清理 app/bin 目录，确保每次都重新下载
echo "清理 app/bin 目录..."
rm -f app/bin/*

# 下载
for arch in "${arches[@]}"; do
  bin="app/bin/komari-linux-$arch"
  url="https://github.com/komari-monitor/komari/releases/download/$version/komari-linux-$arch"
  [[ -n "$mirror" ]] && url="$mirror/$url"

  echo "下载 $arch -> $url"
  curl -L --progress-bar -o "$bin" "$url"
  chmod +x "$bin"
done

# fnpack 构建
echo "fnpack build..."
fnpack build

mv komari.fpk "komari-$version-$out.fpk"

echo "构建完成：$(pwd)/komari-$version-$out.fpk"

