#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_ID="${AGENT_ID:-binance-ai}"
WORKSPACE="${WORKSPACE:-$HOME/.openclaw/workspace-binance-ai}"
MODEL="${MODEL:-mango1/gpt-5.3-codex}"

if ! command -v openclaw >/dev/null 2>&1; then
  echo "[ERROR] openclaw CLI 未安装或不在 PATH 中。"
  exit 1
fi

AGENT_EXISTS=0
if openclaw agents list --json | grep -q "\"id\": \"${AGENT_ID}\""; then
  AGENT_EXISTS=1
fi

if [[ "$AGENT_EXISTS" -eq 0 ]]; then
  echo "[INFO] 创建 Agent: ${AGENT_ID}"
  openclaw agents add "${AGENT_ID}" \
    --workspace "${WORKSPACE}" \
    --model "${MODEL}" \
    --non-interactive \
    --json >/dev/null
else
  echo "[INFO] Agent 已存在: ${AGENT_ID}"
fi

mkdir -p "${WORKSPACE}"
cp "${ROOT_DIR}/templates/AGENTS.md" "${WORKSPACE}/AGENTS.md"
cp "${ROOT_DIR}/templates/IDENTITY.md" "${WORKSPACE}/IDENTITY.md"

openclaw agents set-identity \
  --agent "${AGENT_ID}" \
  --workspace "${WORKSPACE}" \
  --from-identity \
  --json >/dev/null

echo "[OK] Agent 已就绪"
echo "AGENT_ID=${AGENT_ID}"
echo "WORKSPACE=${WORKSPACE}"
echo "MODEL=${MODEL}"
