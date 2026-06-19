# 샷별 프롬프트 템플릿
공통 접미(ugc-day-progression과 동일): `Photorealistic vertical 9:16, authentic UGC influencer smartphone photo, natural cohesive lighting, realistic skin, anatomically correct hands — natural proportions, no extra hands or fingers, no visible camera rig, no text, no watermark. ◆품질: true-to-life natural color, high micro-detail (real skin pores · product texture, no over-smoothing), soft natural light, crisp authentic phone-camera focus. NEGATIVE: plastic/waxy skin, over-glossy·oily highlights, distorted·garbled text/logos, warped anatomy, oversaturation, generic AI sheen.`

## persona (Soul ID 기반 얼굴형)
Soul ID 학습 후 `--soul-id <ref_id>`로 적용. 별도 이미지 프롬프트 없이 Soul ID가 인물 고정.
모델: `text2image_soul_v2` (이미지) / `soul_cinema_studio` (영상).

## board (4분할 스토리보드 보드, 4 step 동시생성)
Wide 4-panel storyboard (left→right = Step 1→4). SAME person, SAME {{wardrobe}}, SAME {{location}}, SAME lighting throughout all panels. Each panel: {{model}} performing step-specific hand action — Panel 1: {{step1_action}}; Panel 2: {{step2_action}}; Panel 3: {{step3_action}}; Panel 4: {{step4_action}}. Each panel has a small caption label "Step N — {{step_label}}" at the bottom. {접미}

## hook (ref=마스터 또는 Soul ID)
{{model}} holding {{product}} up to camera, slight smile, {{wardrobe}}, in {{location}}. Clean background, good light. Hook caption space at top. {접미}

## step_clip (ref=보드 해당 슬롯 or 마스터, 영상 프롬프트)
[보드 슬롯 크롭 이미지를 start 프레임으로 사용]
Motion: {{step_motion_desc}}. Keep person/wardrobe/location/lighting identical to reference. Smooth natural movement, no jump cut. 9:16, kling3_0 pro, 5s, no audio.

## result (ref=마스터 or 마지막 step 이미지)
Use this image as the only reference. Keep SAME person, wardrobe, location, camera framing. Show {{result_desc}} on {{area}}. Natural dewy finish, keep pores, no plastic glow. Push-in motion. {접미}

## cta (마지막 모션 결합 또는 엔드카드)
Option A — 마지막 모션 결합: 마지막 step_clip 말미에 제품을 들어 카메라에 보여주는 동작 추가(start/end 사용). CTA 자막 오버레이.
Option B — 엔드카드: 제품컷 image 레이어 + 하단 title(BRAND, CTA 문구), 3s.
