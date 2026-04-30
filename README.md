# Komari‑fnOS

| 项目   | 内容                                    |
|--------|-----------------------------------------|
| **工具**   | 轻量级服务器监控（fnOS 第三方封装） |
| **端口**   | `25774`                               |
| **架构**   | `x86_64`、`ARM64`                     |
| **源码**   | <https://github.com/komari-monitor/komari> |
| **脚本**   | `build.sh` – 将官方二进制打包为 `.fpk` |

## `build.sh` 简介
- **功能**：自动下载最新的 Komari 二进制并使用 `fnpack` 生成 fnOS 安装包（`.fpk`）。
- **使用方式**：

```bash
# 打包所有架构（推荐）
bash build.sh all

# 仅打包 x86_64
bash build.sh x86

# 仅打包 ARM64
bash build.sh arm

# 使用自定义镜像源（示例）
bash build.sh all mirror=https://mirrors.aliyun.com
```

运行后会在当前目录得到 `komari-<版本>-<arch>.fpk`，即可在 fnOS 中直接安装。
