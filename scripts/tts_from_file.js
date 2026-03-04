#!/usr/bin/env node
const fs = require("fs");
const path = require("path");
const { EdgeTTS } = require("node-edge-tts");

async function main() {
  const textFile = process.argv[2];
  const outFile = process.argv[3];
  const voice = process.argv[4] || "zh-CN-XiaoxiaoNeural";
  const rate = process.argv[5] || "default";

  if (!textFile || !outFile) {
    console.error("Usage: node scripts/tts_from_file.js <text_file> <out_mp3> [voice] [rate]");
    process.exit(1);
  }

  const textPath = path.resolve(textFile);
  if (!fs.existsSync(textPath)) {
    console.error(`Text file not found: ${textPath}`);
    process.exit(1);
  }

  const text = fs.readFileSync(textPath, "utf8").replace(/\s+/g, " ").trim();
  if (!text) {
    console.error("Text file is empty");
    process.exit(1);
  }

  const tts = new EdgeTTS({
    voice,
    lang: "zh-CN",
    outputFormat: "audio-24khz-48kbitrate-mono-mp3",
    rate,
    timeout: 20000,
    saveSubtitles: false,
  });

  await tts.ttsPromise(text, path.resolve(outFile));
  console.log(`TTS generated: ${outFile}`);
}

main().catch((err) => {
  console.error(String(err));
  process.exit(1);
});
