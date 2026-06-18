#!/usr/bin/env bash
# 클린본: prepped 클립들을 순서대로 하드컷으로 이어붙임(자막·엔드카드 없음).
# Usage: assemble_clean.sh --prepped DIR --out CLEAN.mp4
set -euo pipefail
PREPPED=""; OUT=""
while [[ $# -gt 0 ]]; do case "$1" in
  --prepped) PREPPED="$2"; shift 2;; --out) OUT="$2"; shift 2;;
  *) echo "unknown arg: $1" >&2; exit 2;; esac; done
[[ -z "$PREPPED" || -z "$OUT" ]] && { echo "ERROR: --prepped and --out required" >&2; exit 2; }
base=$(cd "$PREPPED" && pwd); tmp=$(mktemp); i=0
while [[ -f "$base/prepped_$i.mp4" ]]; do echo "file '$base/prepped_$i.mp4'" >> "$tmp"; i=$((i + 1)); done
[[ $i -eq 0 ]] && { echo "ERROR: no prepped_*.mp4 in $PREPPED" >&2; rm -f "$tmp"; exit 1; }
mkdir -p "$(dirname "$OUT")"
# prepped는 speed_prep로 균일 인코딩됨 → 무손실 concat
ffmpeg -y -f concat -safe 0 -i "$tmp" -c copy "$OUT" 2>/dev/null || \
  ffmpeg -y -f concat -safe 0 -i "$tmp" -r 24 -c:v libx264 -pix_fmt yuv420p "$OUT" 2>/dev/null
rm -f "$tmp"
ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT"; echo "$OUT"
