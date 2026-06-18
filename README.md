# Ad Factory (Claude Code 플러그인)

제품 에셋과 컨셉으로 숏폼(9:16) 광고영상을 반자동 제작하는 Claude Code 플러그인.
디스커버리(역질문) → 페르소나 → 시놉시스 → 컷신 이미지 → 클립 → editly 편집을 전담 서브에이전트와 **사람 게이트**로 진행합니다.

## 구성
- **스킬**: `ad-factory` (오케스트레이터)
- **서브에이전트 6**: `ad-analyst`(분석·디스커버리) · `ad-persona`(인물 일관성) · `ad-image`(이미지) · `ad-clip`(클립) · `ad-editor`(편집) · `ad-qa`(적대 검수)
- **템플릿 3**: `ugc-review`(토킹헤드, 기본) · `ugc-day-progression`(before/after) · `tutorial-stepflow`(사용법)

## ⚠️ 환경 (설치 전 각자 준비)
이 플러그인은 외부 도구·계정에 의존합니다. **받는 사람이 각자 갖춰야** 합니다. 도구가 없으면 해당 스크립트가 실패하므로, 설치 후 셋업 커맨드로 점검·설치부터 하세요:
```text
/ad-factory:setup        # 점검(DRY) → 승인 → 자동 설치 가능한 것 설치 + editly pull, Docker/higgsfield는 안내
```
수동 점검만 원하면:
```bash
bash skills/ad-factory/scripts/check_env.sh   # 필수/선택·계정·크레딧·없을 때 영향 안내
```

| 항목 | 용도 | 없으면 |
|---|---|---|
| **higgsfield CLI + 본인 계정·크레딧** | 이미지·영상 생성(코어) | **제작 불가** (필수, 계정 공유 X) |
| **ffmpeg** | 속도 전처리·CLEAN 조립·프레임 | **제작 불가** (필수) |
| **python3 + pyyaml** | editly spec 생성 | 편집본 불가 (필수, python3는 대개 기본) |
| **Docker** | editly 편집본 렌더(`vimagick/editly`) | 편집본 못 만듦 → **CLEAN본(ffmpeg)만**, 또는 ImageMagick 자막 폴백 (선택) |
| **ImageMagick** (`magick`) | 자막 폴백(editly 대안) | editly 폴백 자막 불가 (선택) |
| **jq** | OpenAI TTS JSON 인코딩 | OpenAI TTS 불가 → `say`/직접 녹음 (선택) |
| **OpenAI 키** (플러그인 config `openai_api_key` 또는 env `OPENAI_API_KEY`) | OpenAI TTS 보이스 | `say` 또는 직접 녹음 사용 (선택) |
| **macOS** | `say` TTS(빠른 검증용) | 타 OS는 OpenAI TTS 또는 직접 녹음 |

> 참고: **node는 불필요**합니다(editly는 Docker 컨테이너 내부에서 node를 사용).

## 설치

> 📦 **마케터(비개발자)는 단계별 가이드 [INSTALL.md](INSTALL.md)를 보세요** — mac/win, 비공개 repo 접근(`gh auth`·초대), Docker·higgsfield·OpenAI 키 입력까지 그림처럼 따라가도록 정리돼 있습니다.

```bash
# 로컬(개발/시험):
claude --plugin-dir /path/to/ad-factory-plugin

# 마켓플레이스(배포):
/plugin marketplace add <your-org>/<marketplace-repo>
/plugin install ad-factory@<marketplace-name>
```

## 사용
1. 제품 에셋을 `projects/<product>/assets/{product,model,composition,reference}/`에 둔다(오디오 직접 제공 시 `audio/`에 mp3).
2. "이 제품으로 광고 영상 만들어줘" 등으로 `ad-factory`를 발동.
3. `ad-analyst`가 역질문(컨셉·모델·타깃·길이·**언어·오디오 소스**) → 컷신 합의.
4. 페르소나 → 이미지(보드) → 클립 → 편집. **각 단계 사람 게이트**에서 승인.
5. 산출물: `output/FINAL_ad.mp4`(편집본: 자막+엔드카드) + `output/CLEAN_ad.mp4`(클린본).

## 오디오 소스 (토킹헤드)
디스커버리에서 선택: **provided**(직접 녹음 mp3) / **openai**(OpenAI TTS) / **say**(macOS, 검증용). 립싱크라 **오디오는 클립 생성 전 확정**한다.

설치 시 **userConfig**(plugin.json)로 기본값을 한 번 입력해 두면 매번 묻지 않는다:
- `openai_api_key` (**sensitive**) — OpenAI 키. **시스템 키체인**에 저장(평문 X). 스크립트엔 `CLAUDE_PLUGIN_OPTION_openai_api_key`로 전달.
- `tts_engine` (기본 `openai`) · `openai_tts_voice` (기본 `nova`).
- 키가 없으면 `gen_tts.sh`가 자동으로 `say`로 폴백. env `OPENAI_API_KEY`도 그대로 지원(로컬 개발본·env 호환).

## 주의
- **클레임**: 제품의 실제 효능 범위 + 외관 수준 표현만. 의학적·기능성(미백 등) 단정 금지.
- **NSFW**: 신체 노출 부위는 착장 명시·텍스트 묘사로 생성 필터를 회피.
- 모든 생성은 각자의 higgsfield 크레딧을 소모합니다.

## 라이선스
MIT
