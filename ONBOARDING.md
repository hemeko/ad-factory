# 마케터 온보딩 — 운영자용 (복붙)

마케터에게 아래 메시지를 그대로 전달하세요. 실제 설치는 **마케터의 Claude가 가이드를 읽고 도와줍니다.**

---

**ad-factory로 광고 영상 만들기 — 설치 안내**

**1) Claude Code 설치 + 로그인**
- 설치: https://claude.ai/code (macOS는 터미널에서 `curl -fsSL https://claude.ai/install.sh | bash` 도 됨)
- 터미널에서 `claude` 입력 → 브라우저로 로그인

**2) Claude에게 이 한 줄을 그대로 말하세요:**
> "https://raw.githubusercontent.com/hemeko/ad-factory/main/INSTALL.md 를 읽고, 내 OS와 설치 상태를 점검해서 ad-factory 플러그인 설치를 단계별로 도와줘. 로그인·앱 설치(Docker 등)는 내가 직접 할 테니 명령·확인만 주고, 자동으로 가능한 점검·설치는 실행해줘."

→ 그러면 Claude가 가이드를 읽고, 환경을 점검하고, 할 수 있는 건 대신 설치하고, 나머지(Docker 설치·higgsfield 로그인 등)는 단계별로 안내해 줍니다. 막히면 화면을 보여주며 물어보세요.

**3) 설치가 끝나면 — 영상 만들기**
- 제품 자료를 폴더에 정리: `projects/<제품>/{product, model, composition, reference}/`
- Claude에게: **"이 제품으로 광고 영상 만들어줘"**

---

## 마케터가 미리 준비할 것 (각자)
- **higgsfield 계정 + 크레딧** — 이미지·영상 생성에 필수(본인 계정)
- **OpenAI API 키** — 보이스 내레이션용(선택; 없으면 macOS 무료 `say` 또는 무음/직접 녹음)

## 운영자 메모
- 이 repo(`hemeko/ad-factory`)는 **공개**입니다 → 마케터는 GitHub 인증·초대 불필요, 위 링크를 바로 읽습니다.
- 업데이트 배포: 스킬 수정 → `plugin.json`의 `version`↑ → commit·push → 마케터는 `/plugin update`.
- 첫 도입 시 마케터 1명과 **화면 공유로 1회** 같이 설치해보면 가이드의 빈틈을 빨리 찾을 수 있습니다.
