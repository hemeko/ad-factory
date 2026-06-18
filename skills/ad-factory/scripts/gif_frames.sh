#!/usr/bin/env bash
# 레퍼런스 GIF에서 텍스처 매칭용 프레임 추출.
# Usage: gif_frames.sh --gif PATH --out DIR [--every N]
set -euo pipefail
GIF=""; OUT=""; EVERY=1
while [[ $# -gt 0 ]]; do case "$1" in
  --gif) GIF="$2"; shift 2;; --out) OUT="$2"; shift 2;; --every) EVERY="$2"; shift 2;;
  *) echo "unknown arg: $1" >&2; exit 2;; esac; done
[[ -z "$GIF" || -z "$OUT" ]] && { echo "ERROR: --gif and --out required" >&2; exit 2; }
[[ -f "$GIF" ]] || { echo "ERROR: gif not found: $GIF" >&2; exit 1; }
mkdir -p "$OUT"
ffmpeg -y -i "$GIF" -vf "select=not(mod(n\,$EVERY))" -vsync vfr "$OUT/frame_%03d.png" >/dev/null 2>&1
echo "extracted $(find "$OUT" -name 'frame_*.png' | wc -l | tr -d ' ') frames to $OUT"
