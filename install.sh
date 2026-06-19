#!/usr/bin/env bash
# ad-factory 플러그인 설치 스크립트
# 지원: Claude Desktop (Claude Code) / Codex
# 요구사항: macOS, curl, python3 (모두 기본 설치됨)
#
# 사용법:
#   curl -fsSL https://raw.githubusercontent.com/hemeko/ad-factory/main/install.sh | bash

set -euo pipefail

REPO="hemeko/ad-factory"
BRANCH="main"
MARKETPLACE_ID="ad-factory-marketplace"
PLUGIN_NAME="ad-factory"
VERSION="0.2.1"

# ── 색상 ───────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "${GREEN}  [O]${NC} $*"; }
warn() { echo -e "${YELLOW}  [!]${NC} $*"; }
err()  { echo -e "${RED}  [X]${NC} $*"; }

echo "=== ad-factory 플러그인 설치 ==="
echo ""

# ── 1. 사전 점검 ────────────────────────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
  err "macOS 전용 스크립트입니다."
  exit 1
fi

HAS_CLAUDE=0
HAS_CODEX=0
[[ -f "$HOME/.claude/plugins/known_marketplaces.json" && \
   -f "$HOME/.claude/plugins/installed_plugins.json" ]] && HAS_CLAUDE=1
[[ -d "$HOME/.codex/plugins" && -f "$HOME/.codex/config.toml" ]] && HAS_CODEX=1

if [[ $HAS_CLAUDE -eq 0 && $HAS_CODEX -eq 0 ]]; then
  err "Claude Desktop 또는 Codex가 설치되어 있지 않습니다."
  err "  Claude Desktop: https://claude.ai/download"
  err "  Codex:          https://openai.com/codex"
  err "설치 후 한 번 실행한 뒤 다시 시도하세요."
  exit 1
fi

[[ $HAS_CLAUDE -eq 1 ]] && ok "Claude Desktop 확인"
[[ $HAS_CODEX  -eq 1 ]] && ok "Codex 확인"

# ── 2. 다운로드 (공통) ─────────────────────────────────────────────────────────
echo ""
echo "[1/4] 다운로드 중..."

TMP_ZIP=$(mktemp /tmp/ad-factory-XXXXXX.zip)
TMP_DIR=$(mktemp -d /tmp/ad-factory-XXXXXX)
trap 'rm -rf "$TMP_ZIP" "$TMP_DIR"' EXIT

curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.zip" -o "$TMP_ZIP"
unzip -q "$TMP_ZIP" -d "$TMP_DIR"
SRC_DIR="$TMP_DIR/ad-factory-$BRANCH"
rm -rf "$SRC_DIR/.git"

COMMIT_SHA=$(curl -sf "https://api.github.com/repos/$REPO/commits/$BRANCH" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])" 2>/dev/null \
  || echo "unknown")
NOW=$(python3 -c \
  "from datetime import datetime,timezone; \
   print(datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.000Z'))")

ok "다운로드 완료 (${COMMIT_SHA:0:7})"

# ── 3-A. Claude Desktop 설치 ───────────────────────────────────────────────────
install_claude() {
  local PLUGINS_DIR="$HOME/.claude/plugins"
  local MARKETPLACE_DIR="$PLUGINS_DIR/marketplaces/$MARKETPLACE_ID"
  local CACHE_DIR="$PLUGINS_DIR/cache/$MARKETPLACE_ID/$PLUGIN_NAME/$VERSION"

  echo ""
  echo "[2/4] Claude Desktop 플러그인 설치 중..."

  [[ -d "$MARKETPLACE_DIR" ]] && rm -rf "$MARKETPLACE_DIR"
  [[ -d "$CACHE_DIR" ]]       && rm -rf "$CACHE_DIR"

  mkdir -p "$PLUGINS_DIR/marketplaces"
  cp -r "$SRC_DIR" "$MARKETPLACE_DIR"
  mkdir -p "$(dirname "$CACHE_DIR")"
  cp -r "$MARKETPLACE_DIR" "$CACHE_DIR"

  # known_marketplaces.json
  python3 - "$PLUGINS_DIR/known_marketplaces.json" \
            "$MARKETPLACE_ID" "$REPO" "$MARKETPLACE_DIR" "$NOW" <<'PYEOF'
import sys, json
path, marketplace_id, repo, install_loc, now = sys.argv[1:]
with open(path) as f:
    data = json.load(f)
data[marketplace_id] = {
    "source": {"source": "github", "repo": repo},
    "installLocation": install_loc,
    "lastUpdated": now
}
with open(path, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
PYEOF

  # installed_plugins.json
  python3 - "$PLUGINS_DIR/installed_plugins.json" \
            "$PLUGIN_NAME" "$MARKETPLACE_ID" "$CACHE_DIR" \
            "$VERSION" "$NOW" "$COMMIT_SHA" <<'PYEOF'
import sys, json
path, plugin_name, marketplace_id, cache_dir, version, now, sha = sys.argv[1:]
with open(path) as f:
    data = json.load(f)
key = f"{plugin_name}@{marketplace_id}"
data["plugins"][key] = [{
    "scope": "user",
    "installPath": cache_dir,
    "version": version,
    "installedAt": now,
    "lastUpdated": now,
    "gitCommitSha": sha
}]
with open(path, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
PYEOF

  ok "Claude Desktop 플러그인 등록 완료"
}

# ── 3-B. Codex 설치 ────────────────────────────────────────────────────────────
install_codex() {
  local CODEX_DIR="$HOME/.codex"
  local CACHE_DIR="$CODEX_DIR/plugins/cache/$MARKETPLACE_ID/$PLUGIN_NAME/$COMMIT_SHA"
  local CONFIG="$CODEX_DIR/config.toml"
  local PLUGIN_KEY="\"$PLUGIN_NAME@$MARKETPLACE_ID\""

  echo ""
  echo "[2/4] Codex 플러그인 설치 중..."

  # 기존 버전 제거 (SHA가 다른 경우)
  local PARENT
  PARENT="$CODEX_DIR/plugins/cache/$MARKETPLACE_ID/$PLUGIN_NAME"
  [[ -d "$PARENT" ]] && rm -rf "$PARENT"

  mkdir -p "$CACHE_DIR"
  cp -r "$SRC_DIR/." "$CACHE_DIR/"

  # config.toml 에 플러그인 항목 추가 (중복 방지)
  if ! grep -qF "[plugins.$PLUGIN_KEY]" "$CONFIG" 2>/dev/null; then
    printf '\n[plugins.%s]\nenabled = true\n' "$PLUGIN_KEY" >> "$CONFIG"
  fi

  ok "Codex 플러그인 등록 완료"
}

[[ $HAS_CLAUDE -eq 1 ]] && install_claude
[[ $HAS_CODEX  -eq 1 ]] && install_codex

# ── 4. 의존성 설치 ──────────────────────────────────────────────────────────────
echo ""
echo "[3/4] 의존성 확인 중..."

if ! python3 -c "import yaml" 2>/dev/null; then
  warn "pyyaml 없음 → 설치 중..."
  pip3 install --quiet pyyaml && ok "pyyaml 설치 완료" \
    || warn "pyyaml 설치 실패 — 나중에 직접: pip3 install pyyaml"
else
  ok "pyyaml"
fi

if command -v brew >/dev/null 2>&1; then
  if ! command -v ffmpeg >/dev/null 2>&1; then
    warn "ffmpeg 없음 → 설치 중... (1~3분 소요)"
    brew install --quiet ffmpeg 2>/dev/null && ok "ffmpeg 설치 완료" \
      || warn "ffmpeg 설치 실패 — 나중에 직접: brew install ffmpeg"
  else
    ok "ffmpeg"
  fi
  if ! command -v jq >/dev/null 2>&1; then
    warn "jq 없음 → 설치 중..."
    brew install --quiet jq 2>/dev/null && ok "jq 설치 완료" \
      || warn "jq 설치 실패 — 나중에 직접: brew install jq"
  else
    ok "jq"
  fi
else
  warn "Homebrew 없음 — ffmpeg/jq는 https://brew.sh 설치 후 진행하세요."
fi

# ── 5. 완료 ────────────────────────────────────────────────────────────────────
echo ""
echo "[4/4] 환경 점검..."
bash "$SRC_DIR/skills/ad-factory/scripts/check_env.sh" 2>/dev/null || true

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}  ad-factory 설치 완료!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "다음 단계:"
STEP=1
if [[ $HAS_CLAUDE -eq 1 && $HAS_CODEX -eq 1 ]]; then
  echo "  $STEP. Claude Desktop / Codex 완전히 종료 후 재시작"
elif [[ $HAS_CLAUDE -eq 1 ]]; then
  echo "  $STEP. Claude Desktop 완전히 종료 후 재시작"
else
  echo "  $STEP. Codex 완전히 종료 후 재시작"
fi
STEP=2
echo "  $STEP. higgsfield CLI 설치 (공식 사이트 참고)"
STEP=3
echo "  $STEP. higgsfield auth login  ← 본인 계정으로 1회 로그인"
STEP=4
echo "  $STEP. '광고 만들어줘' 입력"
echo ""
if ! command -v higgsfield >/dev/null 2>&1; then
  warn "higgsfield CLI가 설치되어 있지 않습니다. 위 2번 단계를 완료하세요."
fi
