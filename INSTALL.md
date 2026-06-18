# Ad Factory 설치 가이드

제품 자료와 컨셉으로 숏폼(9:16) 광고영상을 반자동 제작하는 Claude Code 플러그인입니다.
**개발 경험이 없어도** 따라 할 수 있게 정리했습니다. 처음 한 번만 세팅하면, 이후엔 "광고 만들어줘" 한 줄로 시작합니다.

> 이 플러그인은 **본인 컴퓨터의 Claude Code**에서 돌아갑니다(claude.ai 웹 채팅 X). 이미지·영상은 본인 컴퓨터에서 생성됩니다.

---

## 🤖 가장 쉬운 방법 — AI에게 설치를 맡기기

**Claude Code를 설치·로그인**한 다음(아래 1단계), Claude에게 이 한 줄을 말하세요:

> **"https://raw.githubusercontent.com/hemeko/ad-factory/main/INSTALL.md 를 읽고, 내 OS와 설치 상태를 점검해서 ad-factory 플러그인 설치를 단계별로 도와줘. 로그인·앱 설치(Docker 등)는 내가 직접 할 테니 명령과 확인만 주고, 자동으로 가능한 점검·설치는 실행해줘."**

그러면 AI가 이 가이드를 읽고, 환경을 점검하고, 할 수 있는 건 대신 실행하고, 나머지는 단계별로 안내해 줍니다. 막히면 그대로 화면을 보여주며 물어보세요.

<!-- ===== AI(Claude)를 위한 설치 도우미 지침 ===== -->
> **AI에게**: 사용자가 이 가이드로 설치를 부탁하면 아래 원칙으로 진행하세요.
> 1. **환경 점검 먼저**: `uname -s`로 OS 확인 + `command -v claude docker higgsfield ffmpeg python3 magick jq`로 설치 상태 점검 후, 무엇이 있고 무엇이 없는지 사용자에게 요약.
> 2. **AI가 자동으로 해도 되는 것**(사용자 승인 후 실행): `brew`/`apt`로 ffmpeg·imagemagick·jq 설치, `python3 -m pip install pyyaml`, 플러그인 설치 후 `/ad-factory:setup` 결과 해석·진단, 제품 폴더 구조 생성.
> 3. **사람이 직접 해야 하는 것**(명령/링크만 제시, 절대 대신 실행 금지 — 브라우저·GUI·슬래시 명령): Claude Code 설치·로그인, **Docker Desktop 설치·실행**, **higgsfield 설치·`higgsfield auth login`·크레딧 충전**, `/plugin marketplace add`·`/plugin install`(슬래시 명령은 사용자가 입력), OpenAI 키 입력.
> 4. **한 번에 한 단계**. 사용자가 "됐어" 하면 다음으로. 오류가 나면 맨 아래 트러블슈팅 표로 진단.
> 5. 설치가 끝나면 제품 폴더 구조를 안내하고 **첫 영상 제작**으로 이끄세요.
<!-- ============================================= -->

직접 따라 하고 싶으면 아래 단계를 보세요.

---

## 0. 미리 준비할 것

| 항목 | 용도 | 준비 방법 |
|---|---|---|
| **Claude Code** | 플러그인 실행 | 아래 1단계에서 설치 |
| **higgsfield 계정 + 크레딧** | 이미지·영상 생성(필수) | higgsfield 가입 → 크레딧 충전 (계정은 **본인 것**) |
| **OpenAI API 키** (선택) | 보이스 내레이션 | platform.openai.com에서 발급. 없으면 macOS는 무료 `say`, 또는 무음/직접 녹음으로 진행 |

> 공개 플러그인이라 **GitHub 계정·초대·인증은 필요 없습니다.**

---

## A. macOS 설치

### 1) Claude Code 설치  〔사람〕
`응용프로그램 > 유틸리티 > 터미널`을 열고:
```bash
curl -fsSL https://claude.ai/install.sh | bash
```
설치 후 터미널을 닫았다 다시 엽니다.

### 2) Claude 로그인  〔사람〕
```bash
claude
```
브라우저가 열리면 Anthropic 계정으로 로그인. (이후 `claude`만 치면 실행)

### 3) Docker Desktop 설치  〔사람〕
- https://docs.docker.com/desktop/ 에서 Mac용 설치 → **앱 실행**(상단바에 고래 아이콘).
- (없으면 자막·엔드카드 편집본은 못 만들고, 클립만 이어붙인 CLEAN본만 나옵니다.)

### 4) 플러그인 설치  〔사람: 슬래시 명령 입력〕
`claude` 안에서:
```text
/plugin marketplace add hemeko/ad-factory
/plugin install ad-factory@ad-factory-marketplace
```

### 5) OpenAI 키 입력  〔사람〕 (보이스 쓸 경우)
플러그인 활성화 시 설정창 → **openai_api_key**에 키 붙여넣기(화면엔 가려짐).
> ⚠ Claude Code에 키 저장이 안 되는 알려진 버그가 있습니다. 보이스가 "키 없음" 오류면 터미널에서 아래 후 `claude` 재실행:
> ```bash
> echo 'export OPENAI_API_KEY="여기에-본인-키"' >> ~/.zshenv
> ```
> 키를 안 쓰면 무료 `say` 또는 직접 녹음 mp3로 대체됩니다.

### 6) 환경 점검·마무리  〔AI 도움 가능 + 사람〕
```text
/ad-factory:setup
```
ffmpeg 등은 자동 설치되고, Docker/higgsfield는 안내가 나옵니다. 마지막으로:
```bash
higgsfield auth login       # 본인 계정으로  〔사람〕
higgsfield account status   # 크레딧 확인
```

---

## B. Windows 설치

### 1) Claude Code 설치  〔사람〕
공식 설치 안내: https://code.claude.com/docs/ (Windows 설치 섹션).
### 2) 로그인 / 3) Docker  〔사람〕
- `claude` 실행 → 브라우저 로그인.
- **Docker Desktop + WSL2**: https://docs.docker.com/desktop/ (Windows + WSL2 안내) → 설치 후 실행.
### 4) 플러그인 설치 — macOS와 동일
```text
/plugin marketplace add hemeko/ad-factory
/plugin install ad-factory@ad-factory-marketplace
```
### 5) OpenAI 키 — Windows 주의
Windows에는 `say`가 없어 보이스를 쓰려면 **OpenAI 키가 사실상 필수**(없으면 무음/직접 녹음). 저장 버그 시 시스템 환경변수에 `OPENAI_API_KEY` 추가 후 재실행.
### 6) `/ad-factory:setup` 실행 후 안내 따르기.

---

## 영상 만들기 (설치 후, 매번)

1. 제품 자료를 폴더에 넣습니다:
   ```text
   projects/<제품이름>/
     ├ product/      ← 제품컷, 제형컷, (있으면)효능 PDF
     ├ model/        ← 모델 사진(없으면 비워둠 = 부위 중심)
     ├ composition/  ← 참고할 구도/톤 이미지
     └ reference/    ← 질감·before/after 등 참고
   ```
2. `claude`에서: **"이 제품으로 광고 영상 만들어줘"**
3. 질문(컨셉·타깃·길이·언어·before/after 여부 등)에 답합니다.
4. **단계마다 확인(게이트)** — 이미지·클립을 보고 OK/수정.
5. 결과: `projects/<제품>/output/FINAL_ad.mp4`(편집본) + `CLEAN_ad.mp4`(클린본).

---

## 자주 막히는 곳

| 증상 | 해결 |
|---|---|
| `/plugin marketplace add`가 안 됨 | 철자 확인(`hemeko/ad-factory`). Claude Code가 최신인지 확인 |
| 편집본이 안 나옴 / Docker 오류 | Docker Desktop 앱이 **실행 중**인지(고래 아이콘) |
| "크레딧 부족" | `higgsfield account status` 확인 후 충전 |
| 보이스가 "키 없음" 오류 | 5단계의 env 폴백 적용, 또는 `say`/직접 녹음 |
| 이미지·영상 생성 실패 | `higgsfield auth login` 재로그인 후 재시도 |
| 그 외 환경 문제 | `/ad-factory:setup` 다시 실행 |

> 처음 세팅이 어려우면 운영자와 **화면 공유로 함께** 진행하거나, 위의 **AI 한 줄 프롬프트**로 Claude에게 맡기세요. 한 번 끝내면 그다음부터는 "광고 만들어줘"만 하면 됩니다.
