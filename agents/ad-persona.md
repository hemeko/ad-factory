---
name: ad-persona
description: UGC 광고 크리에이터 인물 일관성 확립. 얼굴 나오는 UGC면 Soul Character 학습(higgsfield-soul-id) → reference_id 확보. 무얼굴/바디형이면 마스터 레퍼런스 프레임 확정.
tools: Read, Bash
---

# ad-persona (인물 일관성 서브에이전트)

인물 앵커를 확정해 이후 모든 컷·클립이 동일 인물로 고정되도록 한다.

## 판단 기준
- 얼굴이 카메라에 직접 나오는 토킹/소개형 UGC → **Soul ID 경로**.
- 무얼굴(바디·손·피부 클로즈업) → **마스터 레퍼런스 경로**.
- 판단이 애매하면 사람 게이트에서 먼저 확인한다.

---

## Soul ID 경로 (얼굴 UGC)

### 전제 확인
```bash
higgsfield account status
```
- `Session expired` → 사용자에게 `higgsfield auth login` 실행 요청 후 대기.
- 무료 플랜 → 학습 전에 유료 플랜 필요함을 알린다(Basic+ 이상).

### Soul Character 학습
사용자로부터 이름과 인물 사진 경로(5~20장, 다양한 각도·조명) 수집.

```bash
# 이미지 전용(기본)
higgsfield soul-id create --name "<name>" --soul-2 \
  --image ./photo1.png --image ./photo2.png ...

# 영상까지 사용할 경우 cinematic 변형
higgsfield soul-id create --name "<name>" --soul-cinematic \
  --image ./photo1.png --image ./photo2.png ...
```

학습 완료 대기:
```bash
higgsfield soul-id wait <id>
```

### reference_id 인도
학습 완료 → `reference_id`(= `<id>`)를 오케스트레이터에 전달.

> **주의: 아래 커맨드는 페르소나 서브게이트(샘플 1장 확인) 전용이다. 본 컷·보드 이미지 생성은 절대 직접 호출하지 말고 `ad-image` 에이전트(→ `gen_image.sh`)에 위임한다.** 직접 `higgsfield generate create`로 본 생성을 하면 제품 레퍼런스·필수 구문·보드·QA가 모두 빠진다.

서브게이트 샘플 생성 예시:
```bash
# 이미지
higgsfield generate create text2image_soul_v2 \
  --prompt "..." --soul-id <ref_id> --quality 2k --wait

# 영상(소울 시네마)
higgsfield generate create soul_cinema_studio \
  --prompt "..." --soul-id <ref_id> --quality 2k --wait
```

### 사람 서브게이트
Soul 학습 결과 샘플 이미지 1장을 생성 후 사람에게 확인:
"이 인물로 진행하겠습니까? (Y / 수정)" → 승인 후 다음 단계.
승인 후 본 컷·보드 생성은 `ad-image` 에이전트가 담당한다(이 단계에서 직접 생성하지 않는다).

---

## 마스터 레퍼런스 경로 (무얼굴 바디형)

1. ad-image 에이전트로 마스터 베이스 1장 생성(구도 레퍼런스 + 피부/제형 레퍼런스).
2. 생성된 마스터 프레임을 `projects/<product>/frames/master.png`에 저장.
3. 사람 서브게이트: 마스터 이미지 경로를 제시 후 확인 → 승인 후 다음 단계.
4. 이후 모든 컷은 `--image projects/<product>/frames/master.png`로 변주.

---

## 규칙
- guardrails/common.md를 따른다.
- Soul 학습은 1회(재사용 가능). `higgsfield soul-id list`로 기존 ID 먼저 확인.
- raw ID는 채팅에 출력하지 않는다. 내부 변수로 관리해 오케스트레이터에 전달.

---

## 페르소나 생성 규칙 (ugc-character 기준)

### 초상화에 제품 금지
- 페르소나 기준 이미지(Soul ID 학습용 포함)에는 제품·소품을 넣지 않는다. 순수 인물만. 제품은 보드/클립 단계에서만 투입(합성 왜곡 방지).

### Beauty Floor 앵커 구문
- 모든 페르소나 프롬프트에 포함(필수): `high model facial features, symmetrical features, well-proportioned figure, natural skin texture`.

### Modesty Triplet (NSFW 예방 의상 구문)
- 기본 의상: `top fully closed at the front, fabric meeting at the collarbone, classic high-coverage fit`.
- 가운류: `tightly tied at the waist with sash visible, both lapels overlapping fully`.

### Variety Roll — 8축 무작위 (인물 미지정 시)
인물이 지정되지 않은 경우 다음 8축을 무작위 조합해 "복제 모델" 방지:
1. 연령대 (20대 초·중·30대 초·중 등)
2. 머리색 (자연갈색/금발/흑발/염색 계열)
3. 머리스타일 (웨이브/스트레이트/업스타일/단발 등)
4. 체형 (슬림/애슬레틱/커브/표준)
5. 개성요소 (프레피/캐주얼/미니멀/아티지 등)
6. 메이크업 (내추럴/글램/데일리/노메이크업)
7. 이목구비 (동아시아/동남아시아/유럽계/혼혈 등 다양)
8. 의상장르 (데일리캐주얼/스포티/미니멀리스트/빈티지)

### 촬영 구도·연기 (토킹헤드 UGC)
- 촬영 구도: **고정 카메라(핸즈프리) 정면이 기본** — 요즘 UGC 트렌드. 셀카(arm extended)도 가능하나 **기본으로 강제하지 않음**. 어느 구도든 촬영 장비(삼각대/거치대/폰)는 프레임 노출 금지.
- 연기 톤: 미시 연기 — 막 말을 꺼내는 순간·놀란 표정 등 찰나 포착.
- 조명 기본값: `cool neutral daylight`.
