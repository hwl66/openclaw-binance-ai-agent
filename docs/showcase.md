# OpenClaw x 币安主题 AI Agent（一页式展示）

## 项目定位

这是一个基于 OpenClaw 的“币安产品创新顾问”Agent，用于回答：

- 币安哪些功能值得用 AI 创新
- 如何把想法拆成可执行 MVP
- 如何接 Binance Public API 快速搭建最小系统

## Agent 能力

- 输出“创新点 + 落地路径 + KPI + 2周MVP”
- 支持产品、技术、数据三层拆解
- 默认中文，结论优先，强调可执行
- 支持 2 分钟中文配音视频自动生成

## 最小架构图（图文）

```text
用户问题
   |
   v
OpenClaw Agent (binance-ai)
   |
   +--> 创新建议生成（产品层）
   +--> MVP拆解（工程层）
   +--> API接入方案（技术层）
   |
   v
Markdown 图文演示稿 + 中文配音视频
```

## 核心演示问题

1. 你觉得币安有哪些功能或服务可以通过AI实现创新和优化？
2. 请针对“币安用户的AI风险预警+资产体检”给一个2周MVP计划，要求包含数据源、模型方案、KPI。
3. 如果接入币安公开API，请给出最小技术架构与开发任务拆解（后端/前端/数据）。

## 复现命令

```bash
cd /root/openclaw/binance_ai_agent
bash scripts/build_all.sh
```

## 演示产物

- 最新图文稿：`docs/demo_latest.md`
- 历史图文稿：`docs/generated_demo_*.md`
- 演示视频：`docs/assets/demo.mp4`
- 中文 2 分钟视频：`docs/assets/demo-cn-2min.mp4`
- 中文配音音轨：`docs/assets/demo-cn-voice.mp3`
