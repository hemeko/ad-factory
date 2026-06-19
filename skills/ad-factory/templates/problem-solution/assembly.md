# 조립 — problem-solution

## prepped 준비 (오디오 분기)
- **상황 액션·바디형(kling 무음)**: `speed_prep.sh`로 컷별 속도 적용(`-an` 무음). VO는 editly에서 별도 오버레이(클립과 분리 → 나중 교체 가능).
- **토킹헤드 대사(seedance 립싱크)**: speed_prep 건너뛰고 클립 → prepped `cp` + `synopsis_to_editly.py --keep-audio`(보이스 보존).

## 컷 순서
problem → (agitate) → solution → result → endcard

## VO / 대사 (PAS 흐름)
- 액션형 VO 오버레이: Problem(고민 한 줄) → Agitate(공감) → Solution(제품·기대) → Result+CTA. 첫 단어부터 핵심(워밍업 단어 금지). 언어는 디스커버리 확정.
- 토킹헤드면 모놀로그 대사로 같은 PAS 흐름. seedance 립싱크.
- 오디오는 `gen_tts.sh`(say/openai) 또는 사용자 제공 mp3. 액션형 VO는 클립 생성 후 얹어도 됨(립싱크 아님).

## 편집 (ad-editor 폴리시 적용)
- 자막: 고민 한 줄(problem) / 결과(result) / 엔드카드 텍스트. **세이프존·가독성**(긴 자막·엔드카드는 ImageMagick PNG 오버레이 폴백).
- **모션 다양화**: problem/result 이미지 인서트·엔드카드에 켄번스(방향·속도 변주).
- **오디오 정규화**: VO `loudnorm`.
- 하드컷(transition cut). BGM은 수동(사용자 제공 시 `--bgm`).
- 산출물 2개: FINAL(자막+VO+엔드카드) + CLEAN(클립 하드컷).

## QA
- ad-qa: problem↔result **부위·좌우·앵글 일관**(같은 부위가 좋아진 것으로 보일 것), 해부학·클레임(외관 수준)·자막 동기 검수.
