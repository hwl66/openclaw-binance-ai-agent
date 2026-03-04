#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash "${ROOT_DIR}/scripts/setup_binance_ai_agent.sh"
bash "${ROOT_DIR}/scripts/run_demo.sh"
bash "${ROOT_DIR}/scripts/generate_demo_video.sh"
bash "${ROOT_DIR}/scripts/generate_demo_video_cn.sh"

echo "[OK] all assets generated"
