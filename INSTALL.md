# Ad Factory 설치 가이드 (마케터용)

이 문서는 **개발 경험이 없어도** 따라 할 수 있게 단계별로 적었습니다. 막히면 운영자(배포 담당)에게 화면을 보여주며 도움을 받으세요. 처음 한 번만 세팅하면, 이후엔 "광고 만들어줘" 한 줄로 시작합니다.

> 이 플러그인은 **본인 컴퓨터의 Claude Code**에서 돌아갑니다(claude.ai 웹 채팅 X). 이미지·영상은 본인 컴퓨터에서 생성됩니다.

---

## 0. 미리 준비할 것 (이게 없으면 진행 불가)

| 항목 | 용도 | 준비 방법 |
|---|---|---|
| **Claude Code** | 플러그인 실행 | 아래 1단계에서 설치 |
| **GitHub 계정** | 비공개 플러그인 받기 | github.com 가입 후 **운영자에게 "이 repo에 초대해 달라"고 요청** (초대 수락 필수) |
| **higgsfield 계정 + 크레딧** | 이미지·영상 생성(필수) | higgsfield 가입 → 크레딧 충전 (계정은 **본인 것**, 공유 X) |
| **OpenAI API 키** (선택) | 보이스 내레이션 | platform.openai.com에서 발급. 없으면 macOS는 무료 `say`, 또는 무음/직접 녹음으로 진행 가능 |

---

## A. macOS 설치

### 1) Claude Code 설치
`응용프로그램 > 유틸리티 > 터미널`을 열고 붙여넣기:
```bash
curl -fsSL https://claude.ai/install.sh | bash
```
설치 후 터미널을 닫았다 다시 엽니다.

### 2) Claude 로그인
```bash
claude
```
브라우저가 열리면 Anthropic 계정으로 로그인. (이후 `claude`만 치면 실행)

### 3) GitHub 로그인 (비공개 repo 접근 — 필수)
플러그인이 **비공개 저장소**에 있어, 본인 GitHub 계정 인증이 필요합니다.
```bash
# gh 도구가 없다면 먼저 설치:
brew install gh        # Homebrew가 없으면 https://brew.sh 안내대로 설치

gh auth login
# → GitHub.com → HTTPS → 브라우저로 로그인 선택
```
> ⚠ **운영자에게 이 repo의 collaborator(또는 팀)로 초대**받아 두세요. 초대를 수락하지 않으면 다음 단계에서 "저장소를 찾을 수 없음"이 납니다.

### 4) Docker Desktop 설치 (편집본 렌더에 필요)
- https://docs.docker.com/desktop/ 에서 Mac용 Docker Desktop 설치 → **앱을 실행**(고래 아이콘이 상단바에 떠 있어야 함).
- (없으면 자막·엔드카드 편집본은 못 만들고, 클립만 이어붙인 CLEAN본만 나옵니다.)

### 5) 플러그인 설치
`claude`를 실행한 상태에서 입력:
```text
/plugin marketplace add hemeko/ad-factory
/plugin install ad-factory@ad-factory-marketplace
```
(운영자가 알려준 주소입니다 — 여기서는 `hemeko/ad-factory`)

### 6) OpenAI 키 입력 (보이스 쓸 경우)
플러그인을 활성화하면 설정 입력창이 뜹니다 → **openai_api_key** 칸에 키 붙여넣기(화면엔 가려져 보임).
> ⚠ Claude Code에 **키가 저장 안 되는 알려진 버그**가 있습니다. 보이스 생성이 "키 없음" 오류가 나면, 터미널에서 아래 한 줄을 실행하고 `claude`를 다시 켜세요(키는 화면에 안 남습니다):
> ```bash
> echo 'export OPENAI_API_KEY="여기에-본인-키"' >> ~/.zshenv
> ```
> 키를 아예 안 쓰면 보이스는 무료 `say`로 대체되거나, 직접 녹음한 mp3를 쓸 수 있습니다.

### 7) 환경 점검·마무리
```text
/ad-factory:setup
```
화면 안내에 따라 ffmpeg 등은 자동 설치되고, Docker/higgsfield는 안내가 나옵니다. 마지막으로 higgsfield 로그인:
```bash
higgsfield auth login     # 본인 계정으로
higgsfield account status # 크레딧 확인
```

---

## B. Windows 설치

### 1) Claude Code 설치
공식 설치 안내를 따르세요: https://code.claude.com/docs/ (Windows 설치 섹션). 보통 PowerShell 한 줄 또는 설치 프로그램입니다.

### 2) Claude 로그인 / 3) GitHub 로그인 / 4) Docker
- `claude` 실행 → 브라우저 로그인.
- GitHub: `gh auth login`(gh가 없으면 https://cli.github.com 에서 설치). **운영자 초대 수락 필수.**
- **Docker Desktop + WSL2**: https://docs.docker.com/desktop/ (Windows + WSL2 안내대로). 설치 후 실행.

### 5) 플러그인 설치 — macOS와 동일
```text
/plugin marketplace add hemeko/ad-factory
/plugin install ad-factory@ad-factory-marketplace
```

### 6) OpenAI 키 — Windows 주의
- Windows에는 macOS `say`가 **없습니다.** 보이스를 쓰려면 **OpenAI 키가 사실상 필수**(없으면 무음/직접 녹음).
- 설정창에 키 입력. 저장 버그로 오류 나면 시스템 환경변수에 `OPENAI_API_KEY` 추가(제어판 > 시스템 > 고급 > 환경 변수) 후 Claude Code 재실행.

### 7) 환경 점검 — `/ad-factory:setup` 실행 후 안내 따르기.

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
| `/plugin marketplace add`에서 "repo를 찾을 수 없음" | GitHub 초대를 수락했는지, `gh auth login` 했는지 확인 |
| 편집본이 안 나옴 / Docker 오류 | Docker Desktop 앱이 **실행 중**인지 확인(고래 아이콘) |
| "크레딧 부족" | `higgsfield account status` 확인 후 충전 |
| 보이스가 "키 없음" 오류 | 위 6단계의 env 폴백 적용, 또는 `say`/직접 녹음 사용 |
| 이미지·영상 생성 실패 | `higgsfield auth login` 재로그인, 잠시 후 재시도 |
| 그 외 환경 문제 | `/ad-factory:setup` 다시 실행해 점검 |

> 처음 세팅(1~7단계)이 어려우면 운영자와 **화면 공유로 함께** 진행하길 권합니다. 한 번 끝내면 그다음부터는 "광고 만들어줘"만 하면 됩니다.
