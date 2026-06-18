#!/usr/bin/env bash
# Nano Banana Pro로 이미지 생성 후 다운로드.
# Usage: gen_image.sh --prompt "..." [--image REF]... --out PATH [--aspect 9:16] [--res 2k] [--dry-run]
set -euo pipefail
ASPECT="9:16"; RES="2k"; OUT=""; PROMPT=""; DRY=0; IMAGES=()
while [[ $# -gt 0 ]]; do case "$1" in
  --prompt) PROMPT="$2"; shift 2;; --image) IMAGES+=("$2"); shift 2;; --out) OUT="$2"; shift 2;;
  --aspect) ASPECT="$2"; shift 2;; --res) RES="$2"; shift 2;; --dry-run) DRY=1; shift;;
  *) echo "unknown arg: $1" >&2; exit 2;; esac; done
[[ -z "$PROMPT" ]] && { echo "ERROR: --prompt required" >&2; exit 2; }
[[ -z "$OUT" ]] && { echo "ERROR: --out required" >&2; exit 2; }
args=(generate create nano_banana_2 --prompt "$PROMPT" --aspect_ratio "$ASPECT" --resolution "$RES" --wait)
for img in "${IMAGES[@]:-}"; do [[ -n "$img" ]] && args+=(--image "$img"); done
if [[ "$DRY" == "1" ]]; then printf 'higgsfield'; printf ' %q' "${args[@]}"; printf '\n'; exit 0; fi
url=""; out_raw=""; attempt=0
while [[ $attempt -lt 3 && -z "$url" ]]; do
  attempt=$((attempt + 1))
  out_raw=$(higgsfield "${args[@]}" 2>&1) || true
  url=$(printf '%s' "$out_raw" | grep -oE 'https://[^ ]+\.(png|jpe?g)' | tail -1)
done
if [[ -z "$url" ]]; then echo "ERROR: no image URL after 3 attempts. Last CLI output:" >&2; printf '%s\n' "$out_raw" >&2; exit 1; fi
mkdir -p "$(dirname "$OUT")"; curl -fsSL -o "$OUT" "$url"; echo "$OUT"
