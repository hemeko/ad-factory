#!/usr/bin/env bash
# 보이스(내레이션) 오디오 생성 → seedance --audio용 mp3.
# 백엔드: macOS say(무료·오프라인, 검증용) 또는 OpenAI TTS(자연스러움, 광고용).
# Usage:
#   gen_tts.sh --engine say    --text "..." --out PATH [--voice Samantha]            # 영어 Samantha / 한국어 Yuna 등
#   gen_tts.sh --engine openai --text "..." --out PATH [--voice nova] [--model tts-1-hd]
#     voice: alloy/echo/fable/onyx/nova/shimmer
#     ★ OpenAI 키: env OPENAI_API_KEY, 또는 플러그인 userConfig(openai_api_key, 키체인) → CLAUDE_PLUGIN_OPTION_openai_api_key.
#       (둘 다 시도. 키는 인자/로그로 받지 않음.)
# ※ 기본 엔진/voice는 플러그인 config(tts_engine/openai_tts_voice)에서 폴백 — 인자가 있으면 인자 우선.
# ※ 사용자가 직접 녹음/준비한 오디오는 이 스크립트 없이 audio/에 mp3로 두면 됨(생성 스킵).
set -euo pipefail
ENGINE="${CLAUDE_PLUGIN_OPTION_tts_engine:-say}"; TEXT=""; OUT=""; VOICE=""; MODEL="tts-1-hd"
while [[ $# -gt 0 ]]; do case "$1" in
  --engine) ENGINE="$2"; shift 2;; --text) TEXT="$2"; shift 2;; --out) OUT="$2"; shift 2;;
  --voice) VOICE="$2"; shift 2;; --model) MODEL="$2"; shift 2;;
  *) echo "unknown arg: $1" >&2; exit 2;; esac; done
[[ -z "$TEXT" || -z "$OUT" ]] && { echo "ERROR: --text, --out required" >&2; exit 2; }
mkdir -p "$(dirname "$OUT")"

if [[ "$ENGINE" == "say" ]]; then
  voice="${VOICE:-Samantha}"
  tmp="$(mktemp -t tts).aiff"
  say -v "$voice" -o "$tmp" "$TEXT"
  ffmpeg -nostdin -y -i "$tmp" "$OUT" 2>/dev/null
  rm -f "$tmp"

elif [[ "$ENGINE" == "openai" ]]; then
  # 키: env(OPENAI_API_KEY) 우선 → 없으면 플러그인 userConfig(sensitive)가 주입하는 CLAUDE_PLUGIN_OPTION_openai_api_key.
  KEY="${OPENAI_API_KEY:-${CLAUDE_PLUGIN_OPTION_openai_api_key:-}}"
  [[ -z "$KEY" ]] && { echo "ERROR: OpenAI 키 없음 — env OPENAI_API_KEY 또는 플러그인 config openai_api_key 설정 필요" >&2; exit 1; }
  voice="${VOICE:-${CLAUDE_PLUGIN_OPTION_openai_tts_voice:-nova}}"
  # jq로 안전하게 JSON 인코딩(따옴표·줄바꿈 등). 키는 헤더에 환경변수로만 전달.
  payload="$(jq -n --arg m "$MODEL" --arg v "$voice" --arg i "$TEXT" \
    '{model:$m, voice:$v, input:$i, response_format:"mp3"}')"
  http="$(curl -sS -w '%{http_code}' https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" \
    -d "$payload" --output "$OUT")"
  if [[ "$http" != "200" ]]; then
    echo "ERROR: OpenAI TTS 실패 (HTTP $http). 응답 본문:" >&2
    cat "$OUT" >&2 2>/dev/null; rm -f "$OUT"; exit 1
  fi

else
  echo "ERROR: --engine은 say 또는 openai 만 지원" >&2; exit 2
fi

# 무음/빈파일 방지 검증
dur="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT" 2>/dev/null || echo 0)"
[[ -z "$dur" || "$dur" == "0" ]] && { echo "ERROR: 생성된 오디오가 비어있음: $OUT" >&2; exit 1; }
echo "$OUT"
