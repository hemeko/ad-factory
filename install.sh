#!/usr/bin/env bash
# ad-factory Claude Code 플러그인 설치 스크립트
# 요구사항: macOS + Claude Desktop (curl, python3 는 기본 설치됨)
#
# 사용법:
#   curl -fsSL https://raw.githubusercontent.com/hemeko/ad-factory/main/install.sh | bash

set -euo pipefail

REPO="hemeko/ad-factory"
BRANCH="main"
MARKETPLACE_ID="ad-factory-marketplace"
PLUGIN_NAME="ad-factory"
VERSION="0.2.1"

PLUGINS_DIR="$HOME/.claude/plugins"
MARKETPLACE_DIR="$PLUGINS_DIR/marketplaces/$MARKETPLACE_ID"
CACHE_DIR="$PLUGINS_DIR/cache/$MARKETPLACE_ID/$PLUGIN_NAME/$VERSION"
KNOWN_MARKETPLACES="$PLUGINS_DIR/known_marketplaces.json"
INSTALLED_PLUGINS="$PLUGINS_DIR/installed_plugins.json"

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

if [[ ! -d "$PLUGINS_DIR" ]]; then
  err "Claude Desktop이 설치되어 있지 않습니다."
  err "https://claude.ai/download 에서 설치 후 다시 실행하세요."
  exit 1
fi

if [[ ! -f "$KNOWN_MARKETPLACES" || ! -f "$INSTALLED_PLUGINS" ]]; then
  err "Claude Desktop 플러그인 설정 파일을 찾을 수 없습니다."
  err "Claude Desktop을 한 번 실행한 뒤 다시 시도하세요."
  exit 1
fi

ok "Claude Desktop 확인"

# ── 2. 다운로드 ─────────────────────────────────────────────────────────────────
echo ""
echo "[1/4] 다운로드 중..."

TMP_ZIP=$(mktemp /tmp/ad-factory-XXXXXX.zip)
TMP_DIR=$(mktemp -d /tmp/ad-factory-XXXXXX)
trap 'rm -rf "$TMP_ZIP" "$TMP_DIR"' EXIT

curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.zip" -o "$TMP_ZIP"
ok "다운로드 완료"

# ── 3. 플러그인 파일 배치 ──────────────────────────────────────────────────────
echo ""
echo "[2/4] 설치 중..."

# 기존 설치 제거
[[ -d "$MARKETPLACE_DIR" ]] && rm -rf "$MARKETPLACE_DIR"
[[ -d "$CACHE_DIR" ]]       && rm -rf "$CACHE_DIR"

# 마켓플레이스 디렉토리 (git 제외)
mkdir -p "$PLUGINS_DIR/marketplaces"
unzip -q "$TMP_ZIP" -d "$TMP_DIR"
mv "$TMP_DIR/ad-factory-$BRANCH" "$MARKETPLACE_DIR"
rm -rf "$MARKETPLACE_DIR/.git"

# 캐시 디렉토리 (플러그인 실제 실행 경로)
mkdir -p "$(dirname "$CACHE_DIR")"
cp -r "$MARKETPLACE_DIR" "$CACHE_DIR"

ok "파일 배치 완료"

# ── 4. JSON 등록 ────────────────────────────────────────────────────────────────
echo ""
echo "[3/4] 플러그인 등록 중..."

COMMIT_SHA=$(curl -sf "https://api.github.com/repos/$REPO/commits/$BRANCH" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])" 2>/dev/null \
  || echo "unknown")

NOW=$(python3 -c \
  "from datetime import datetime,timezone; \
   print(datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.000Z'))")

# known_marketplaces.json
python3 - "$KNOWN_MARKETPLACES" "$MARKETPLACE_ID" "$REPO" "$MARKETPLACE_DIR" "$NOW" <<'PYEOF'
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
python3 - "$INSTALLED_PLUGINS" "$PLUGIN_NAME" "$MARKETPLACE_ID" "$CACHE_DIR" "$VERSION" "$NOW" "$COMMIT_SHA" <<'PYEOF'
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

ok "플러그인 등록 완료"

# ── 5. 의존성 설치 ──────────────────────────────────────────────────────────────
echo ""
echo "[4/4] 의존성 확인 중..."

# pyyaml (python3는 기본 설치)
if ! python3 -c "import yaml" 2>/dev/null; then
  warn "pyyaml 없음 → 설치 중..."
  pip3 install --quiet pyyaml && ok "pyyaml 설치 완료" || warn "pyyaml 설치 실패 — 나중에 직접: pip3 install pyyaml"
else
  ok "pyyaml"
fi

# brew 확인
if command -v brew >/dev/null 2>&1; then
  # ffmpeg
  if ! command -v ffmpeg >/dev/null 2>&1; then
    warn "ffmpeg 없음 → 설치 중... (1~3분 소요)"
    brew install --quiet ffmpeg 2>/dev/null && ok "ffmpeg 설치 완료" \
      || warn "ffmpeg 설치 실패 — 나중에 직접: brew install ffmpeg"
  else
    ok "ffmpeg"
  fi
  # jq
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

# ── 완료 ───────────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}  ad-factory 설치 완료!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "다음 단계:"
echo "  1. Claude Desktop 완전히 종료 후 재시작"
echo "  2. higgsfield CLI 설치 (공식 사이트 참고)"
echo "  3. higgsfield auth login  ← 본인 계정으로 1회 로그인"
echo "  4. Claude Desktop에서 '광고 만들어줘' 입력"
echo ""
if ! command -v higgsfield >/dev/null 2>&1; then
  warn "higgsfield CLI가 설치되어 있지 않습니다. 위 2번 단계를 완료하세요."
fi
