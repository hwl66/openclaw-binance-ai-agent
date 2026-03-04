#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_FILE="${1:-${ROOT_DIR}/docs/assets/demo.mp4}"
ASS_FILE="${ROOT_DIR}/scripts/demo_video.ass"

if [[ ! -f "${ASS_FILE}" ]]; then
  echo "[ERROR] ASS subtitle file not found: ${ASS_FILE}"
  exit 1
fi

if [[ ! -d "${ROOT_DIR}/node_modules/ffmpeg-static" ]]; then
  echo "[INFO] installing ffmpeg-static..."
  npm i ffmpeg-static --prefix "${ROOT_DIR}" >/dev/null
fi

FFMPEG_BIN="$(node -e "process.stdout.write(require('ffmpeg-static'))" --workdir "${ROOT_DIR}" 2>/dev/null || true)"
if [[ -z "${FFMPEG_BIN}" ]]; then
  # Fallback for older Node versions that don't support --workdir
  FFMPEG_BIN="$(cd "${ROOT_DIR}" && node -e "process.stdout.write(require('ffmpeg-static'))")"
fi

if [[ -z "${FFMPEG_BIN}" || ! -x "${FFMPEG_BIN}" ]]; then
  echo "[ERROR] ffmpeg-static binary not found"
  exit 1
fi

mkdir -p "$(dirname "${OUT_FILE}")"

"${FFMPEG_BIN}" \
  -hide_banner \
  -loglevel error \
  -f lavfi -i "color=c=#0b0e11:s=1280x720:d=21" \
  -vf "ass=${ASS_FILE}" \
  -c:v libx264 \
  -preset veryfast \
  -pix_fmt yuv420p \
  -movflags +faststart \
  -y "${OUT_FILE}"

echo "[OK] Demo video generated: ${OUT_FILE}"
