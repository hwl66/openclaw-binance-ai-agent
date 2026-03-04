#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_ID="${AGENT_ID:-binance-ai}"
OUT_DIR="${OUT_DIR:-${ROOT_DIR}/docs}"
mkdir -p "${OUT_DIR}"

bash "${ROOT_DIR}/scripts/setup_binance_ai_agent.sh" >/dev/null

TS="$(date '+%Y-%m-%d_%H%M%S')"
OUT_FILE="${OUT_DIR}/generated_demo_${TS}.md"

strip_ansi() {
  perl -pe 's/\e\[[0-9;]*[A-Za-z]//g'
}

run_turn() {
  local prompt="$1"
  local response

  if ! response="$(openclaw agent --agent "${AGENT_ID}" --local --timeout 180 --message "${prompt}" 2>&1)"; then
    response="[ERROR] openclaw 调用失败：${response}"
  fi

  {
    echo "## 用户提问"
    echo
    echo '```text'
    echo "${prompt}"
    echo '```'
    echo
    echo "## Agent 回复"
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

run_turn "你觉得币安有哪些功能或服务可以通过AI实现创新和优化？"
run_turn "请针对“币安用户的AI风险预警+资产体检”给一个2周MVP计划，要求包含数据源、模型方案、KPI。"
run_turn "如果接入币安公开API，请给出最小技术架构与开发任务拆解（后端/前端/数据）。"

echo "[OK] 图文演示已生成：${OUT_FILE}"
