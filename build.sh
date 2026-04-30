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

mkdir -p app/bin data

# 获取 GitHub 最新 tag_name
version=$(curl -sL https://api.github.com/repos/komari-monitor/komari/releases/latest |
          grep tag_name | head -1 | cut -d'"' -f4)

# 更新 manifest 版本
sed -i "s|^version=.*|version=$version|" manifest

# 下载或跳过
for arch in "${arches[@]}"; do
  bin="app/bin/komari-linux-$arch"

  if [[ -f "$bin" ]]; then
    local_ver=$("$bin" -h 2>&1 | head -n 1 | sed -E 's/.*Komari Monitor ([0-9.]+).*/\1/')

    if [[ "$local_ver" == "$version" ]]; then
      echo "$arch 本地版本已为 $version，跳过下载"
      rmdir ./data/theme;rmdir ./data
      chmod +x "$bin"
      continue
    fi
  fi

  url="https://github.com/komari-monitor/komari/releases/download/$version/komari-linux-$arch"
  [[ -n "$mirror" ]] && url="$mirror/$url"

  echo "下载 $arch -> $url"
  curl -L --progress-bar -o "$bin" "$url"
  chmod +x "$bin"
done

# fnpack 构建
fnpack build
mv komari.fpk "komari-$version-$out.fpk"

echo "构建完成：$(pwd)/komari-$version-$out.fpk"

