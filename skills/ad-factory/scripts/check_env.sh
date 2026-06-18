#!/usr/bin/env bash
# ad-factory 환경 점검 — 작업 시작 전 실행 권장.
# 필수/선택 도구를 확인하고, 없을 때의 영향과 설치 안내를 출력한다.
# 의존성이 없으면 스크립트들이 "command not found"로 실패하므로, 먼저 이걸로 점검한다.
echo "=== ad-factory 환경 점검 ==="
req_ok=1
chk() {  # name cmd required|optional purpose hint
  local name="$1" cmd="$2" req="$3" purpose="$4" hint="$5"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf "  [O] %-11s %s\n" "$name" "$purpose"
  elif [[ "$req" == "required" ]]; then
    printf "  [X] %-11s (필수) %s\n        → %s\n" "$name" "$purpose" "$hint"; req_ok=0
  else
    printf "  [!] %-11s (선택) %s\n        → %s\n" "$name" "$purpose" "$hint"
  fi
}
chk higgsfield higgsfield required "이미지·영상 생성(코어)"        "higgsfield CLI 설치 + 본인 계정 로그인(각자 계정·크레딧)"
chk ffmpeg     ffmpeg     required "속도 전처리·CLEAN 조립·프레임"  "brew install ffmpeg (apt: ffmpeg)"
chk python3    python3    required "editly spec 생성(편집본)"        "python3 (대개 기본 설치)"
chk docker     docker     optional "editly 편집본 렌더"              "Docker Desktop. 없으면 CLEAN본(ffmpeg)만 가능 / 자막은 ImageMagick 폴백"
chk magick     magick     optional "자막 폴백(editly 대안)"          "brew install imagemagick"
chk jq         jq         optional "OpenAI TTS JSON 인코딩"          "brew install jq. 없으면 say 또는 직접 녹음(provided)"

# python yaml(필수 — synopsis 파싱)
if command -v python3 >/dev/null 2>&1; then
  if python3 -c "import yaml" >/dev/null 2>&1; then printf "  [O] %-11s %s\n" "pyyaml" "synopsis.yaml 파싱"
  else printf "  [X] %-11s (필수) synopsis 파싱\n        → pip install pyyaml\n" "pyyaml"; req_ok=0; fi
fi

# docker 데몬 실행 여부(설치돼 있어도 꺼져 있을 수 있음)
if command -v docker >/dev/null 2>&1; then
  docker info >/dev/null 2>&1 && echo "  [O] docker 데몬   실행 중" || echo "  [!] docker 데몬   꺼짐 → Docker 앱 실행 필요(편집본 렌더 전)"
fi

# 계정/크레딧
if command -v higgsfield >/dev/null 2>&1; then
  echo "  - higgsfield 계정: $(higgsfield account status 2>&1 | head -1)"
fi

# TTS 가용성
echo "  - TTS: macOS say=$(command -v say >/dev/null 2>&1 && echo 가능 || echo '없음(타 OS → OpenAI/녹음)') · OpenAI=$([ -n "${OPENAI_API_KEY:-}" ] && echo 'key 설정됨' || echo 'key 없음(say/녹음 사용)')"

echo "---"
if [[ $req_ok == 1 ]]; then
  echo "필수 도구 충족 → 제작 가능. (선택 [!] 항목은 해당 기능 사용 시에만 필요)"
else
  echo "⚠ 필수 도구 누락([X]) → 위 안내대로 설치 후 다시 점검하세요. higgsfield/ffmpeg/python3+pyyaml 없이는 제작 불가."
fi
