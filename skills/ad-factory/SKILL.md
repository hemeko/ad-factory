---
name: ad-factory
description: 제품 에셋과 컨셉으로 숏폼 광고영상을 반자동 제작. 디스커버리(역질문)→페르소나→시놉시스→컷신 이미지→클립→editly 조립을 분석/페르소나/이미지/QA 에이전트와 사람 게이트로 진행. "광고 만들어줘", "UGC 영상", "Day1~7 before/after", "제품 사용법 영상", "제품 광고 영상"에 사용.
---

# ad-factory (오케스트레이터)

제품 에셋 + 컨셉으로 숏폼 광고를 반자동 제작. 전담 서브에이전트를 디스패치하고, 각 단계는 자체검수(QA) 후 **사람 게이트**에서 승인. 결정적 작업은 ${CLAUDE_SKILL_DIR}/scripts/로 실행.

## 스크립트 경로 (플러그인/로컬 호환)
- 이 스킬의 스크립트는 **`${CLAUDE_SKILL_DIR}/scripts/`** 에 있다. `${CLAUDE_SKILL_DIR}`는 이 SKILL.md가 있는 디렉토리로 치환되어 플러그인 설치·로컬 `.claude/skills`·프로젝트 모두 동작한다. 모든 스크립트 호출은 이 경로로.
- **서브에이전트 주의**: 서브에이전트(ad-clip/ad-editor 등) 컨텍스트에는 `${CLAUDE_SKILL_DIR}`가 설정되지 않을 수 있다. 디스패치할 때 **오케스트레이터가 scripts 절대경로를 프롬프트에 풀어서 전달**한다(예: 먼저 `echo ${CLAUDE_SKILL_DIR}/scripts`로 실제 경로를 확인해 에이전트에게 `SCRIPTS_DIR=<절대경로>`로 넘김).

## 준비
- `projects/<product>/assets/`에 종류별 하위폴더로 둔다: `product/`(제품컷·제형컷) · `reference/`(고마쥬 GIF·증상 레퍼런스) · `model/`(모델·피부톤 레퍼런스) · `composition/`(포즈·구도 레퍼런스). (토킹헤드 오디오를 직접 제공하면 `audio/`에 mp3.)
- `bash ${CLAUDE_SKILL_DIR}/scripts/check_env.sh`로 환경 점검(필수/선택 도구·계정·크레딧·없을 때 영향 안내). **필수**=higgsfield(+각자 본인 계정·크레딧)·ffmpeg·python3(+pyyaml); **선택**=docker(편집본 렌더; 없으면 CLEAN본만)·magick(자막 폴백)·jq(OpenAI TTS). editly는 Docker 이미지 vimagick/editly로 실행.

## 워크플로우 기반 (공통 엔진 — 모든 컨셉에 항상 적용)
어떤 광고든 아래 "기반" 위에서 만들어진다(컨셉 무관). 이게 워크플로우의 토대이고, 템플릿은 그 위에 얹는 "서사 모양"일 뿐이다.
- **가드레일**(`guardrails/common.md`): 보드 거리대역 교차·그립물리·제품 실제스케일·오버레이금지·연속성/뚜껑, Beauty Floor·Modesty Triplet(NSFW예방), 하드컷 기본·팔레트일치·미드액션훅·CTA테일.
- **페르소나**(ad-persona): 인물 일관성(얼굴=Soul ID / 바디=마스터), Variety Roll, 구도 자유(고정 카메라 기본·셀카 옵션, 장비 미노출).
- **디스커버리**(ad-analyst): **전환 관점 제품 분석 → 전환율 높은 시놉시스 기획안 2~3안 추천·합의** → 역질문·제작설정·(토킹헤드면) 모놀로그 대본. ★시놉시스(서사)가 먼저고, **템플릿은 합의된 시놉시스를 더 완성도 높게 구현하는 레이어**(시놉시스→템플릿).

## 내러티브 템플릿 (기본값 = 토킹헤드 UGC)
- **`ugc-review` — 기본값(default).** 토킹헤드 Hook→Main→Closer. 일반 UGC 광고/리뷰의 표준 구조. **특별한 사유가 없으면 이걸로 간다.**
- 특수 변형(specialization) — 제품·목적이 그 구조를 요구할 때만:
  - **`ugc-day-progression`**: 시간경과 before/after(Day 1~7)가 핵심일 때 → 날별 장소·패션·포즈 변주.
  - **`tutorial-stepflow`**: 단계별 사용법(Step 1~N)이 핵심일 때 → 같은 세션 고정 + 4분할 보드.

## 보드 규칙 (핵심)
- **거리 대역 교차**: 한 보드 슬롯들은 Tight·Mid·Wide를 고루 섞음(같은 거리만 쓰면 컷 전환 울렁거림).
- **해부학적 정합성**: 손 2개로 자연스럽게 소화되는 동작만(여분 손·손가락 방지). 촬영 장비(삼각대·거치대)는 프레임 노출 금지. 상세는 guardrails/common.md.
- **오버레이 금지**: 보드 시트엔 텍스트·화살표·플레이스홀더 금지 — 순수 실사만.

## 영상 생성 모델 선택
- **토킹헤드·립싱크 UGC(ugc-review)**: `seedance_2_0` — 립싱크·오디오·다중 레퍼런스 지원. kling3_0은 무음·립싱크 없어 토킹헤드 부적합.
- **액션·롤링·바디형(ugc-day-progression, tutorial-stepflow)**: `kling3_0` (pro, 9:16, 5s, 무음).

## 파이프라인 (5 전담 에이전트 + ad-qa 횡단)

ad-qa는 독립 에이전트로 각 단계 산출물을 자체검수한다(횡단 QA).

1. **디스커버리**: Agent(ad-analyst) → brief.yaml + synopsis.yaml(템플릿 결정 포함). → 〈사람 빠른 확인: 컷신 목록·템플릿 조정〉
2. **페르소나**: Agent(ad-persona) → 얼굴 UGC면 Soul Character 학습(`higgsfield-soul-id`) → `reference_id` 확보(이후 `--soul-id`로 사용); 무얼굴 바디형이면 마스터 레퍼런스 1장 확정. → 〈페르소나 서브게이트: 사람 확인〉
3. **이미지**: Agent(ad-image) → **마스터/보드 서브게이트**: 마스터 또는 4분할 보드 1장 생성 → 사람 빠른 확인 → 통과 후 나머지 컷 생성(ad-image) → frames/ (마스터→변주 또는 보드 슬롯 분할, ad-qa 자체검수). → 〈게이트1: 이미지 승인〉(컷별 수정은 해당 컷만 재호출)
4. **클립**: Agent(ad-clip) → (토킹헤드면 먼저 **오디오 확정**: `gen_tts.sh`로 say/openai 생성 또는 사용자 제공 mp3 — `brief.audio_source` {provided|openai|say}. 립싱크라 클립 생성 전 확정) → synopsis 각 컷 모델 선택(토킹헤드/립싱크=seedance_2_0, 액션/롤링/바디=kling3_0) → ${CLAUDE_SKILL_DIR}/scripts/gen_clip.sh(start[/end], 연속롤링, --audio/--image 다중 레퍼런스) → clips/. 각 클립 ad-qa 자체검수. → 〈게이트2: 클립 승인〉
5. **편집**: Agent(ad-editor) → cuts.txt → speed_prep → prepped. 편집 폴리시(BGM·자막 대비·엔드카드 켄번스·CTA테일·하드컷) 적용. **항상 산출물 2개**:
   - **편집본** `output/FINAL_ad.mp4`: synopsis_to_editly.py[--bgm] → spec.json → render_editly_docker.sh (자막+엔드카드 켄번스줌+BGM).
   - **클린본** `output/CLEAN_ad.mp4`: assemble_clean.sh (클립만 하드컷 이어붙임, 자막·엔드카드 없음).
   ad-qa 최종 검수. → 〈게이트3: 최종 승인〉

## 규칙
- 항상 guardrails/common.md를 따른다. 일관성은 마스터→변주(바디형) 또는 Soul ID(얼굴형).
- **storyboard-board 기법(옵션)**: 여러 step/컷을 한 장의 와이드 보드로 동시 생성 후 9:16 슬롯 분할 → 컷 간 일관성 구조적 보장. tutorial-stepflow에서 권장.
- 게이트 수정 지시는 해당 컷·단계만 재생성.
- 생성/렌더 전 자체검수로 낭비를 줄인다. editly 설치 실패 시 부록 폴백(ffmpeg+ImageMagick).

## 산출물 (모든 작업 = 영상 2개)
- `projects/<product>/output/`: **`FINAL_ad.mp4`(편집본: 자막+엔드카드)** + **`CLEAN_ad.mp4`(클린본: 클립만 하드컷 이어붙임)**.
- 그 외: brief.yaml, synopsis.yaml, frames/, clips/, prepped/.
