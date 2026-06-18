# 조립 레시피 (editly)
1) 컷 순서: hook → step1 → step2 → ... → stepN → result → cta(엔드카드 또는 마지막 모션).
2) 속도(speed_prep, setpts 배수): hook≈0.8, step 클립=0.7(사용법 가독성), result=1.0.
   → prepped_*.mp4.
3) [편집본] synopsis_to_editly.py로 editly 스펙 생성: 컷=clip(video+title), 자막=captions맵, **트랜지션 하드컷(`--transition cut`, UGC 진정성 기본)**. (kling 무음이라 `--keep-audio` 불필요)
4) 자막 규칙:
   - hook: 훅 문구(상단 또는 하단).
   - step 클립: `Step N — <행동>` (하단 자막, 크고 명확하게).
   - result: 결과 문구.
   - cta: CTA 문구(Option A = 동작 말미 오버레이, Option B = 엔드카드 하단 title).
5) 엔드카드(Option B): 제품컷 image 레이어 + 하단 title(BRAND, CTA), 3s.
6) BGM: --bgm으로 트랙 지정(선택). 출력 1080·9:16.
7) editly 렌더(Docker): ${CLAUDE_SKILL_DIR}/scripts/render_editly_docker.sh --spec spec.json → output/FINAL_ad.mp4.
8) [클린본] assemble_clean.sh --prepped prepped --out output/CLEAN_ad.mp4 (클립만 하드컷 이어붙임, 자막·엔드카드 없음).
