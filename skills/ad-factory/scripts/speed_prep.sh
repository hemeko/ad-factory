#!/usr/bin/env bash
# 컷별 재생속도 변경(setpts)+정규화 전처리.
# Usage: speed_prep.sh --cuts cuts.txt --outdir DIR [--fps 24] [--keep-audio]
#   cuts.txt: "clip_path|speed"  (speed: setpts 배수, 0.5=2배속, 1=원속, 0.6≈1.67배속)
#   --keep-audio: 클립 오디오 보존(토킹헤드 립싱크 보이스 등). 기본은 -an(무음).
#                 속도≠1이면 atempo=1/speed로 오디오도 함께 늘리/줄여 싱크 유지.
#                 단 립싱크 클립은 speed=1.0 권장(속도 변경 시 음성 피치/싱크 영향).
set -euo pipefail
CUTS=""; OUTDIR=""; FPS=24; KEEP_AUDIO=0
while [[ $# -gt 0 ]]; do case "$1" in
  --cuts) CUTS="$2"; shift 2;; --outdir) OUTDIR="$2"; shift 2;; --fps) FPS="$2"; shift 2;;
  --keep-audio) KEEP_AUDIO=1; shift;;
  *) echo "unknown arg: $1" >&2; exit 2;; esac; done
[[ -z "$CUTS" || -z "$OUTDIR" ]] && { echo "ERROR: --cuts and --outdir required" >&2; exit 2; }
mkdir -p "$OUTDIR"; i=0
while IFS='|' read -r clip speed; do
  [[ -z "${clip// }" ]] && continue; speed="${speed:-1}"; out="$OUTDIR/prepped_$i.mp4"
  if [[ "$KEEP_AUDIO" == "1" ]]; then
    atempo=$(awk "BEGIN{print 1/$speed}")  # atempo 권장 범위 0.5~2.0 (speed 0.5~2.0)
    ffmpeg -nostdin -y -i "$clip" -filter:v "setpts=${speed}*PTS" -filter:a "atempo=${atempo}" \
      -r "$FPS" -c:v libx264 -pix_fmt yuv420p -c:a aac "$out" 2>/dev/null
  else
    ffmpeg -nostdin -y -i "$clip" -filter:v "setpts=${speed}*PTS" -an \
      -r "$FPS" -c:v libx264 -pix_fmt yuv420p "$out" 2>/dev/null
  fi
  echo "$out"; i=$((i+1))
done < "$CUTS"
