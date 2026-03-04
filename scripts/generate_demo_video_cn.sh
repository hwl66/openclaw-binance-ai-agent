#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DURATION_SEC="${TARGET_DURATION_SEC:-120}"
VOICE_NAME="${VOICE_NAME:-zh-CN-XiaoxiaoNeural}"
VOICE_RATE="${VOICE_RATE:-+10%}"

NARRATION_FILE="${NARRATION_FILE:-${ROOT_DIR}/scripts/demo_narration_cn.txt}"
ASS_FILE="${ASS_FILE:-${ROOT_DIR}/scripts/demo_video_cn_2min.ass}"
VOICE_OUT="${VOICE_OUT:-${ROOT_DIR}/docs/assets/demo-cn-voice.mp3}"
VIDEO_OUT="${VIDEO_OUT:-${ROOT_DIR}/docs/assets/demo-cn-2min.mp4}"

if [[ ! -f "${NARRATION_FILE}" ]]; then
  echo "[ERROR] narration file not found: ${NARRATION_FILE}"
  exit 1
fi

if [[ ! -f "${ASS_FILE}" ]]; then
  echo "[ERROR] ass file not found: ${ASS_FILE}"
  exit 1
fi

if [[ ! -f "${ROOT_DIR}/package-lock.json" ]]; then
  echo "[INFO] package-lock.json missing, running npm install..."
  npm install --prefix "${ROOT_DIR}" >/dev/null
fi

for dep in ffmpeg-static node-edge-tts; do
  if [[ ! -d "${ROOT_DIR}/node_modules/${dep}" ]]; then
    echo "[INFO] installing missing dependency: ${dep}"
    npm i "${dep}" --prefix "${ROOT_DIR}" >/dev/null
  fi
done

FFMPEG_BIN="$(cd "${ROOT_DIR}" && node -e "process.stdout.write(require('ffmpeg-static'))")"
if [[ -z "${FFMPEG_BIN}" || ! -x "${FFMPEG_BIN}" ]]; then
  echo "[ERROR] ffmpeg-static binary not found"
  exit 1
fi

TMP_RAW_MP3="$(mktemp /tmp/openclaw_cn_tts_raw_XXXX.mp3)"
TMP_FIXED_MP3="$(mktemp /tmp/openclaw_cn_tts_fixed_XXXX.mp3)"
cleanup() {
  rm -f "${TMP_RAW_MP3}" "${TMP_FIXED_MP3}"
}
trap cleanup EXIT

mkdir -p "$(dirname "${VOICE_OUT}")" "$(dirname "${VIDEO_OUT}")"

node "${ROOT_DIR}/scripts/tts_from_file.js" \
  "${NARRATION_FILE}" \
  "${TMP_RAW_MP3}" \
  "${VOICE_NAME}" \
  "${VOICE_RATE}"

DURATION_SEC="$(FFMPEG_BIN="${FFMPEG_BIN}" RAW_AUDIO="${TMP_RAW_MP3}" python3 - <<'PY'
import os
import re
import subprocess

ff = os.environ["FFMPEG_BIN"]
audio = os.environ["RAW_AUDIO"]
p = subprocess.run([ff, "-hide_banner", "-i", audio], capture_output=True, text=True)
m = re.search(r"Duration:\s*(\d+):(\d+):(\d+(?:\.\d+)?)", p.stderr)
if not m:
    print("0")
else:
    h, mm, ss = m.groups()
    total = int(h) * 3600 + int(mm) * 60 + float(ss)
    print(f"{total:.6f}")
PY
)"

ATEMPO_FILTER="$(DURATION_SEC="${DURATION_SEC}" TARGET="${TARGET_DURATION_SEC}" python3 - <<'PY'
import os

d = float(os.environ.get("DURATION_SEC", "0") or "0")
t = float(os.environ.get("TARGET", "120") or "120")
if d <= 0 or t <= 0:
    print("anull")
    raise SystemExit(0)

ratio = d / t
factors = []
while ratio > 2.0:
    factors.append(2.0)
    ratio /= 2.0
while ratio < 0.5:
    factors.append(0.5)
    ratio /= 0.5
factors.append(ratio)
print(",".join(f"atempo={x:.6f}" for x in factors))
PY
)"

"${FFMPEG_BIN}" \
  -hide_banner \
  -loglevel error \
  -i "${TMP_RAW_MP3}" \
  -af "${ATEMPO_FILTER},apad=pad_dur=${TARGET_DURATION_SEC}" \
  -t "${TARGET_DURATION_SEC}" \
  -ar 24000 \
  -ac 1 \
  -y "${TMP_FIXED_MP3}"

cp "${TMP_FIXED_MP3}" "${VOICE_OUT}"

"${FFMPEG_BIN}" \
  -hide_banner \
  -loglevel error \
  -f lavfi -i "color=c=#0b0e11:s=1280x720:d=${TARGET_DURATION_SEC}" \
  -i "${TMP_FIXED_MP3}" \
  -vf "ass=${ASS_FILE}" \
  -c:v libx264 \
  -preset veryfast \
  -pix_fmt yuv420p \
  -c:a aac \
  -b:a 128k \
  -shortest \
  -movflags +faststart \
  -t "${TARGET_DURATION_SEC}" \
  -y "${VIDEO_OUT}"

echo "[OK] Chinese voiceover audio: ${VOICE_OUT}"
echo "[OK] Chinese 2min video: ${VIDEO_OUT}"
