# 조립 레시피 (editly) — ugc-review

## 컷 순서
hook → main → closer(+cta_tail) → [endcard: 선택]

## prepped 준비 (보이스 보존이 핵심)
토킹헤드 립싱크 클립은 속도 1.0이고 **보이스가 주 메시지**다. `speed_prep`(기본 `-an`)을 쓰면 보이스가 사라지므로 **클립을 그대로 복사**한다 — 이게 가장 안전한 길:
```bash
i=0; for id in hook main closer; do
  cp projects/<product>/clips/$id.mp4 projects/<product>/prepped/prepped_$i.mp4; i=$((i+1)); done
```
(미세 속도조정이 꼭 필요하면 `speed_prep.sh --keep-audio` — 오디오까지 atempo로 함께 늘림. 단 립싱크는 1.0 권장.)

## 트랜지션
- **하드컷 기본(`--transition cut`)**: UGC 진정성. 디졸브/페이드 금지.

## 편집본(FINAL) — synopsis_to_editly.py + editly
```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/synopsis_to_editly.py \
  --synopsis projects/<product>/synopsis.yaml \
  --prepped projects/<product>/prepped \
  --captions projects/<product>/captions.json \
  --out projects/<product>/spec.json \
  --outpath projects/<product>/output/FINAL_ad.mp4 \
  --keep-audio \          # 토킹헤드: 클립 보이스 보존(빠지면 무음 영상)
  --transition cut \
  [--bgm projects/<product>/audio/bgm.mp3]

bash ${CLAUDE_SKILL_DIR}/scripts/render_editly_docker.sh --spec projects/<product>/spec.json --repo "$(pwd)"
```

## 클린본(CLEAN) — 클립만 하드컷 이어붙임 (자막·엔드카드 없음)
```bash
bash ${CLAUDE_SKILL_DIR}/scripts/assemble_clean.sh \
  --prepped projects/<product>/prepped \
  --out projects/<product>/output/CLEAN_ad.mp4
```

## 자막 규칙
- hook: 훅 문구 자막 (선택, 상단 또는 하단). 립싱크 오디오가 주 메시지.
- main: 자막 없음 또는 짧은 키워드 강조.
- closer: 자막 없음.
- cta_tail: CTA 문구("Link in bio" / "{{cta_text}}") 하단 자막, 크고 명확하게.

## CTA 테일 처리
- **Option A (권장)**: closer 클립 말미 0.5~1초에 손가락 아래 가리키기 동작 포함. editly에서 closer 끝에 자막 오버레이.
- **Option B**: 별도 1s 클립(cta_tail.mp4) 생성 후 closer 뒤에 연결.

## 엔드카드 (선택)
- 제품컷 image 레이어 + 하단 title(BRAND, CTA) + Ken Burns 줌인, 3s. synopsis.yaml에 `id: endcard` 컷 추가.

## BGM
- `--bgm`으로 배경 트랙 지정(선택). 립싱크 보이스 레벨이 BGM보다 높아야 함.

## 검증
- 렌더 후 `ffmpeg -i FINAL_ad.mp4 -af volumedetect -f null -`로 보이스가 무음이 아닌지 확인(mean ≈ -91dB이면 무음 = `--keep-audio` 누락).
- 출력: FINAL 1080×1920(자막+엔드카드), CLEAN 클립 원해상도. 둘 다 9:16.
