#!/usr/bin/env bash
# ad-factory 셋업 — 의존성 점검 + 가능한 것 자동 설치 + editly 이미지 pull.
# 안전: 기본은 DRY(점검·계획만). 실제 설치는 --install.
#   setup.sh            # DRY: 무엇이 필요한지·무엇을 설치할지 보여줌
#   setup.sh --install  # 실제 설치(ffmpeg/imagemagick/jq, pyyaml, editly pull). sudo가 필요할 수 있음.
# Docker Desktop 설치 자체와 higgsfield(설치+로그인)는 자동화하지 않고 안내만 한다.
set -uo pipefail
INSTALL=0; [[ "${1:-}" == "--install" ]] && INSTALL=1
os="$(uname -s)"
pm=""
if command -v brew >/dev/null 2>&1; then pm=brew
elif command -v apt-get >/dev/null 2>&1; then pm=apt; fi

run() {  # desc cmd...
  local desc="$1"; shift
  if [[ $INSTALL == 1 ]]; then echo "  → $desc: $*"; "$@" || echo "    [실패] $desc — 수동 설치 필요";
  else echo "  (계획) $desc: $*"; fi
}

echo "=== ad-factory setup (os=$os, pkg=${pm:-none}, mode=$([[ $INSTALL == 1 ]] && echo INSTALL || echo DRY)) ==="

# 1) CLI 패키지: ffmpeg, imagemagick, jq
need=()
for pair in ffmpeg:ffmpeg magick:imagemagick jq:jq; do
  cmd="${pair%%:*}"; pkg="${pair##*:}"
  command -v "$cmd" >/dev/null 2>&1 || need+=("$pkg")
done
if [[ ${#need[@]} -eq 0 ]]; then echo "  [O] ffmpeg/imagemagick/jq 충족"
else case "$pm" in
  brew) run "패키지 설치" brew install "${need[@]}";;
  apt)  run "패키지 설치" sudo apt-get install -y "${need[@]}";;
  *)    echo "  [!] 패키지매니저(brew/apt) 없음 → 수동 설치: ${need[*]}";;
esac; fi

# 2) python3 + pyyaml
if command -v python3 >/dev/null 2>&1; then
  if python3 -c "import yaml" >/dev/null 2>&1; then echo "  [O] python3 + pyyaml 충족"
  else run "pyyaml 설치" python3 -m pip install --user pyyaml; fi
else echo "  [X] python3 없음(필수) → 설치 필요(대개 OS 기본 제공)"; fi

# 3) Docker + editly 이미지
if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    if docker image inspect vimagick/editly >/dev/null 2>&1; then echo "  [O] editly 이미지 보유"
    else run "editly 이미지 pull" docker pull --platform linux/amd64 vimagick/editly; fi
  else
    echo "  [!] Docker 설치됨, 데몬 꺼짐 → Docker 앱 실행 후 재시도(editly pull)"
  fi
else
  echo "  [!] Docker 없음 → 편집본(자막·엔드카드) 렌더 불가. CLEAN본(클립 이어붙이기)은 ffmpeg만으로 가능."
  case "$os" in
    Darwin) echo "       설치(택1): brew install --cask docker  /  https://docs.docker.com/desktop/ (설치 후 앱 실행)";;
    Linux)  echo "       설치: https://docs.docker.com/engine/install/";;
    *)      echo "       설치: https://docs.docker.com/get-docker/";;
  esac
fi

# 4) higgsfield (자동 불가 — 안내)
if command -v higgsfield >/dev/null 2>&1; then
  echo "  [O] higgsfield 설치됨 — $(higgsfield account status 2>&1 | head -1)"
else
  echo "  [X] higgsfield 없음(필수·코어) → CLI 설치 후 'higgsfield auth login' (각자 본인 계정·크레딧)"
fi

echo "---"
if [[ $INSTALL == 1 ]]; then echo "설치 시도 완료 → 'check_env.sh'로 재점검 권장."
else echo "DRY(점검·계획만). 실제 설치: setup.sh --install  · Docker/higgsfield는 위 안내대로 직접."; fi
