# 조립 레시피 (editly) — ugc-day-progression
1) 컷 순서: intro → day들(오름차순) → payoff → endcard.
2) 속도(speed_prep, setpts 배수): intro≈0.6, day 롤링=0.5, payoff=1.0. → prepped_*.mp4. (kling 무음이라 `--keep-audio` 불필요)
3) [편집본] synopsis_to_editly.py로 editly 스펙 생성: 컷=clip(video+title), 자막=captions맵, **트랜지션 하드컷(`--transition cut`, UGC 진정성 기본)**. → render_editly_docker.sh → output/FINAL_ad.mp4.
4) [클린본] assemble_clean.sh --prepped prepped --out output/CLEAN_ad.mp4 (클립만 하드컷 이어붙임, 자막·엔드카드 없음).
5) 엔드카드: 제품컷 image 레이어 + 하단 title(BRAND, PRODUCT NAME) + Ken Burns 줌인, 3s.
6) BGM: --bgm으로 트랙 지정(선택). 출력 1080·9:16.
