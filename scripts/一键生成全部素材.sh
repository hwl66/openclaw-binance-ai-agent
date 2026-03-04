#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash "${ROOT_DIR}/scripts/初始化币安智能体.sh"
bash "${ROOT_DIR}/scripts/生成图文演示.sh"
bash "${ROOT_DIR}/scripts/生成演示视频.sh"
bash "${ROOT_DIR}/scripts/生成中文配音视频.sh"

echo "[OK] all assets generated"
