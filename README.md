# OpenClaw Binance AI Agent

![cover](docs/assets/cover.svg)

基于 OpenClaw 的“币安主题 AI Agent”最小可复现项目，包含：

- Agent 配置脚本（自动创建 `binance-ai` Agent）
- 币安创新顾问指令模板（`AGENTS.md` / `IDENTITY.md`）
- 一键图文 Demo 脚本（自动跑多轮问答并生成 Markdown 展示稿）
- 2 分钟中文配音视频自动生成（含音轨导出）

## 首屏演示图

![demo-first-screen](docs/assets/demo-first-screen.svg)

## 演示视频

- 直接下载：[`docs/assets/demo.mp4`](docs/assets/demo.mp4)
- 中文配音 2 分钟版：[`docs/assets/demo-cn-2min.mp4`](docs/assets/demo-cn-2min.mp4)
- 中文配音音轨：[`docs/assets/demo-cn-voice.mp3`](docs/assets/demo-cn-voice.mp3)
- 重新生成：

```bash
bash scripts/generate_demo_video.sh
bash scripts/generate_demo_video_cn.sh
```

## 快速开始

```bash
cd /root/openclaw/binance_ai_agent
bash scripts/build_all.sh
```

运行结束后会输出图文文件路径，例如：

`/root/openclaw/binance_ai_agent/docs/generated_demo_2026-03-04_220000.md`

## 输出文件

- 一页展示：[docs/showcase.md](docs/showcase.md)
- 最新图文稿：[docs/demo_latest.md](docs/demo_latest.md)
- 演示视频：[docs/assets/demo.mp4](docs/assets/demo.mp4)
- 中文 2 分钟视频：[docs/assets/demo-cn-2min.mp4](docs/assets/demo-cn-2min.mp4)
- 中文配音音轨：[docs/assets/demo-cn-voice.mp3](docs/assets/demo-cn-voice.mp3)
- 历史图文稿：`docs/generated_demo_*.md`

## 功能优化（本次）

- `run_demo.sh` 支持通过 `PROMPTS_FILE` 自定义问题清单（按行配置）
- 自动更新 `docs/demo_latest.md`，便于外部展示引用
- 新增 `build_all.sh` 一键构建全量成果（图文 + 英文短视频 + 中文 2 分钟视频）
- 新增 `tts_from_file.js`，支持从文本文件生成中文配音

## 可调参数

可通过环境变量覆盖默认值：

- `AGENT_ID`（默认 `binance-ai`）
- `WORKSPACE`（默认 `~/.openclaw/workspace-binance-ai`）
- `MODEL`（默认 `mango1/gpt-5.3-codex`）
- `OUT_DIR`（默认 `docs/`）
- `PROMPTS_FILE`（默认 `scripts/demo_prompts_cn.txt`）
- `VOICE_NAME`（默认 `zh-CN-XiaoxiaoNeural`）
- `VOICE_RATE`（默认 `+10%`）
- `TARGET_DURATION_SEC`（默认 `120`）

## 说明

该项目优先交付“图文展示”。如需“视频演示”，可基于生成的 Markdown 内容录屏终端执行过程。
