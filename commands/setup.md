---
description: ad-factory 실행 환경 셋업 — 의존성 점검 + 자동 설치 가능한 것(ffmpeg/imagemagick/jq/pyyaml/editly 이미지 pull) + Docker Desktop·higgsfield 안내.
---

ad-factory 실행 환경을 셋업한다. 스크립트 경로는 `${CLAUDE_PLUGIN_ROOT}/skills/ad-factory/scripts/` (변수가 치환되지 않으면 이 플러그인 폴더의 `skills/ad-factory/scripts/`를 사용).

절차:
1. **DRY 점검** — 무엇이 없고 무엇을 설치할지 먼저 보여준다(아무것도 바꾸지 않음):
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/skills/ad-factory/scripts/setup.sh
   ```
2. 출력된 **설치 계획을 사용자에게 보여주고 승인**받는다(네트워크 다운로드·`sudo`·`brew`/`apt` 설치가 포함될 수 있음 — 사전 동의 필수).
3. 승인 시 **실제 설치** (ffmpeg/imagemagick/jq, pyyaml, editly 이미지 pull):
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/skills/ad-factory/scripts/setup.sh --install
   ```
4. **자동화하지 않는 항목**은 출력 안내대로 사용자가 직접 처리한다:
   - **Docker Desktop**: GUI 앱·권한·라이선스 동의가 필요하므로 설치는 안내만(설치 후 앱 실행). 없으면 편집본은 못 만들고 CLEAN본만 가능.
   - **higgsfield**: CLI 설치 + `higgsfield auth login`(각자 본인 계정·크레딧).
5. 마무리로 재점검:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/skills/ad-factory/scripts/check_env.sh
   ```

원칙: 파괴적·시스템 변경(설치)은 항상 사용자 승인 후. 키·계정 정보는 출력/로그에 남기지 않는다.
