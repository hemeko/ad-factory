#!/usr/bin/env bash
# Nano Banana Pro로 이미지 생성 후 다운로드.
# Usage: gen_image.sh --prompt "..." [--image REF]... --out PATH [--aspect 9:16] [--res 2k] [--skip-anchor-check] [--no-product] [--dry-run]
set -euo pipefail
ASPECT="9:16"; RES="2k"; OUT=""; PROMPT=""; DRY=0; IMAGES=()
SKIP_ANCHOR=0; NO_PRODUCT=0
while [[ $# -gt 0 ]]; do case "$1" in
  --prompt) PROMPT="$2"; shift 2;; --image) IMAGES+=("$2"); shift 2;; --out) OUT="$2"; shift 2;;
  --aspect) ASPECT="$2"; shift 2;; --res) RES="$2"; shift 2;; --dry-run) DRY=1; shift;;
  --skip-anchor-check) SKIP_ANCHOR=1; shift;; --no-product) NO_PRODUCT=1; shift;;
  *) echo "unknown arg: $1" >&2; exit 2;; esac; done
[[ -z "$PROMPT" ]] && { echo "ERROR: --prompt required" >&2; exit 2; }
[[ -z "$OUT" ]] && { echo "ERROR: --out required" >&2; exit 2; }
# preflight: prompt anchors. Source of truth = guardrails/common.md.
#   HARD (BLOCK): Anatomical 'no extra hands' — applies to all person prompts (common.md anatomical rule).
#   SOFT (WARN):  Beauty Floor 'symmetrical features' (persona/face cuts only) and
#                 Modesty 'collarbone' (only when wardrobe is in frame) — not universal, so warn not block.
if [[ "$SKIP_ANCHOR" != "1" ]]; then
  shopt -s nocasematch
  if [[ "$PROMPT" != *"no extra hands"* ]]; then
    shopt -u nocasematch
    echo "ERROR: required anatomical anchor missing: 'no extra hands' (no extra hands, fingers, or limbs)" >&2
    echo "Add it to --prompt, or pass --skip-anchor-check to override (use only for non-person shots)." >&2
    exit 2
  fi
  soft_missing=()
  [[ "$PROMPT" == *"symmetrical features"* ]] || soft_missing+=("Beauty Floor (symmetrical features) — add for persona/face cuts")
  [[ "$PROMPT" == *"collarbone"* ]]           || soft_missing+=("Modesty Triplet (collarbone) — add when wardrobe is in frame")
  shopt -u nocasematch
  if [[ ${#soft_missing[@]} -gt 0 ]]; then
    echo "WARN: context anchors missing (ignore if not applicable to this cut):" >&2
    printf '      - %s\n' "${soft_missing[@]}" >&2
  fi
fi
# preflight: product reference (WARN only — product-less hook/closer cuts are legitimate)
if [[ "$NO_PRODUCT" != "1" && ${#IMAGES[@]} -eq 0 ]]; then
  echo "WARN: no --image reference supplied. If this cut shows the product," >&2
  echo "      pass the real product shot via --image to prevent shape drift." >&2
  echo "      Use --no-product to suppress this warning for product-less cuts." >&2
fi
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
