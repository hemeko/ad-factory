#!/usr/bin/env bash
# 클립 생성 후 다운로드. kling3_0(기본) 또는 seedance_2_0 선택.
# Usage:
#   gen_clip.sh --prompt "..." --start PATH [--end PATH] --out PATH \
#               [--model kling3_0|seedance_2_0] [--audio PATH] \
#               [--image REF]... [--dur 5] [--mode pro] [--aspect 9:16] [--dry-run]
#
# kling3_0:   --start-image, --end-image, --dur, --mode, --aspect (--sound off 고정)
# seedance_2_0: --start-image, --end-image, --image(복수), --audio, --dur(4~15), --aspect
#               (--mode/--sound 없음; 오디오는 --audio 미디어 role)
set -euo pipefail

MODEL="kling3_0"; DUR=5; MODE="pro"; ASPECT="9:16"; SOUND="off"
OUT=""; PROMPT=""; START=""; END=""; AUDIO=""
IMAGES=()   # seedance --image refs (반복 가능)
DRY=0

while [[ $# -gt 0 ]]; do case "$1" in
  --prompt)  PROMPT="$2";  shift 2;;
  --start)   START="$2";   shift 2;;
  --end)     END="$2";     shift 2;;
  --out)     OUT="$2";     shift 2;;
  --model)   MODEL="$2";   shift 2;;
  --audio)   AUDIO="$2";   shift 2;;
  --image)   IMAGES+=("$2"); shift 2;;
  --dur)     DUR="$2";     shift 2;;
  --mode)    MODE="$2";    shift 2;;
  --aspect)  ASPECT="$2";  shift 2;;
  --sound)   SOUND="$2";   shift 2;;   # kling3_0 전용; seedance는 무시
  --dry-run) DRY=1;        shift;;
  *) echo "unknown arg: $1" >&2; exit 2;;
esac; done

[[ -z "$PROMPT" || -z "$START" || -z "$OUT" ]] && {
  echo "ERROR: --prompt, --start, --out required" >&2; exit 2
}

# ── 모델별 커맨드 조립 ──────────────────────────────────────────────────────
if [[ "$MODEL" == "seedance_2_0" ]]; then
  # seedance_2_0: 오디오=미디어 role, --image 복수, --mode/--sound 없음
  args=(generate create seedance_2_0
    --prompt "$PROMPT"
    --start-image "$START"
    --aspect_ratio "$ASPECT"
    --duration "$DUR"
  )
  [[ -n "$END" ]]   && args+=(--end-image "$END")
  [[ -n "$AUDIO" ]] && args+=(--audio "$AUDIO")
  for ref in "${IMAGES[@]+"${IMAGES[@]}"}"; do
    args+=(--image "$ref")
  done
  args+=(--wait --wait-timeout 20m)

elif [[ "$MODEL" == "kling3_0" ]]; then
  # kling3_0: --mode/--sound 지원, --image/--audio 없음
  args=(generate create kling3_0
    --prompt "$PROMPT"
    --start-image "$START"
    --aspect_ratio "$ASPECT"
    --duration "$DUR"
    --mode "$MODE"
    --sound "$SOUND"
    --wait --wait-timeout 20m
  )
  [[ -n "$END" ]] && args+=(--end-image "$END")

else
  echo "ERROR: unknown --model '$MODEL'. Supported: kling3_0, seedance_2_0" >&2; exit 2
fi

# ── dry-run ──────────────────────────────────────────────────────────────────
if [[ "$DRY" == "1" ]]; then
  printf 'higgsfield'
  printf ' %q' "${args[@]}"
  printf '\n'
  exit 0
fi

# ── 생성 (3회 재시도) ─────────────────────────────────────────────────────────
url=""; out_raw=""; attempt=0
while [[ $attempt -lt 3 && -z "$url" ]]; do
  attempt=$((attempt + 1))
  out_raw=$(higgsfield "${args[@]}" 2>&1) || true
  url=$(printf '%s' "$out_raw" | grep -oE 'https://[^ ]+\.mp4' | tail -1)
done

if [[ -z "$url" ]]; then
  echo "ERROR: no clip URL after 3 attempts. Last CLI output:" >&2
  printf '%s\n' "$out_raw" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT")"
curl -fsSL -o "$OUT" "$url"
echo "$OUT"
