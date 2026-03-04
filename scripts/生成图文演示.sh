#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_ID="${AGENT_ID:-binance-ai}"
OUT_DIR="${OUT_DIR:-${ROOT_DIR}/docs}"
PROMPTS_FILE="${PROMPTS_FILE:-${ROOT_DIR}/scripts/演示问题清单.txt}"
AGENT_TIMEOUT_SEC="${AGENT_TIMEOUT_SEC:-180}"
mkdir -p "${OUT_DIR}"

bash "${ROOT_DIR}/scripts/初始化币安智能体.sh" >/dev/null

TS="$(date '+%Y-%m-%d_%H%M%S')"
OUT_FILE="${OUT_DIR}/历史演示稿_${TS}.md"
TURN_INDEX=0

strip_ansi() {
  perl -pe 's/\e\[[0-9;]*[A-Za-z]//g'
}

run_turn() {
  local prompt="$1"
  local response
  TURN_INDEX=$((TURN_INDEX + 1))

  if ! response="$(openclaw agent --agent "${AGENT_ID}" --local --timeout "${AGENT_TIMEOUT_SEC}" --message "${prompt}" 2>&1)"; then
    response="[ERROR] openclaw 调用失败：${response}"
  fi

  {
    echo "## 用户提问 ${TURN_INDEX}"
    echo
    echo '```text'
    echo "${prompt}"
    echo '```'
    echo
    echo "## Agent 回复 ${TURN_INDEX}"
    echo
    echo '```text'
    printf '%s\n' "${response}" | strip_ansi
    echo '```'
    echo
    echo "---"
    echo
  } >>"${OUT_FILE}"
}

cat >"${OUT_FILE}" <<EOF
# OpenClaw 币安主题 AI Agent 图文演示

- 生成时间：$(date '+%Y-%m-%d %H:%M:%S %Z')
- Agent ID：${AGENT_ID}
- 执行命令：\`openclaw agent --agent ${AGENT_ID} --local --message "<prompt>"\`

## 演示目标

围绕主题“币安有哪些功能或服务可以通过 AI 实现创新和优化”，展示该 Agent 的回答质量与落地能力。

---

EOF

if [[ -f "${PROMPTS_FILE}" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    if [[ -z "${line}" || "${line}" == \#* ]]; then
      continue
    fi
    run_turn "${line}"
  done < "${PROMPTS_FILE}"
else
  run_turn "你觉得币安有哪些功能或服务可以通过AI实现创新和优化？"
  run_turn "请针对“币安用户的AI风险预警+资产体检”给一个2周MVP计划，要求包含数据源、模型方案、KPI。"
  run_turn "如果接入币安公开API，请给出最小技术架构与开发任务拆解（后端/前端/数据）。"
fi

cp "${OUT_FILE}" "${OUT_DIR}/最新演示稿.md"

echo "[OK] 图文演示已生成：${OUT_FILE}"
