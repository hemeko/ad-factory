# 샷별 프롬프트 템플릿 — ugc-review
공통 접미: `Photorealistic vertical 9:16, authentic UGC influencer smartphone selfie, cool neutral daylight, natural cohesive lighting, realistic skin, anatomically correct hands and body — exactly two hands, natural proportions, no extra hands or fingers, no visible camera rig (tripod/stand/selfie-stick), no text, no watermark, no overlay. ◆품질: true-to-life natural color, high micro-detail (real skin pores · product texture, no over-smoothing), soft natural light, crisp authentic phone-camera focus. NEGATIVE: plastic/waxy skin, over-glossy·oily highlights, distorted·garbled text/logos, warped anatomy, oversaturation, generic AI sheen.`

---

## board (16:9 wide 보드 — 9:16 슬롯 3개)
Wide 3-panel storyboard board (16:9 canvas, three 9:16 vertical slots side by side, separated by thin white gutters). SAME person throughout all panels — {{model_desc}}, {{wardrobe_desc}}, {{location_desc}}, cool neutral daylight.
- Slot 1 (Hook — {{distance_band_1}}): {{hook_action_desc}}. Mid-action moment, not a static smile.
- Slot 2 (Main — {{distance_band_2}}): {{main_action_desc}}. Holding or demonstrating {{product}}.
- Slot 3 (Closer — {{distance_band_3}}): {{closer_action_desc}}. Confident, warm expression.
No text, no arrows, no labels, no placeholders on any panel. Pure photorealistic imagery only.
`high model facial features, symmetrical features, well-proportioned figure, natural skin texture`
`top fully closed at the front, fabric meeting at the collarbone, classic high-coverage fit`
front-facing framing (fixed/hands-free camera by default, natural selfie optional), no camera rig visible. {접미}

## hook (ref=보드 Slot 1 크롭 + 인물앵커[Soul ID 또는 persona 마스터])
[보드 Slot 1 크롭 이미지를 레퍼런스로 사용]
{{model_desc}} in mid-action moment — {{hook_action_desc}}. front-facing framing (fixed/hands-free camera by default, natural selfie optional, no camera rig visible), {{wardrobe_desc}}, {{location_desc}}, cool neutral daylight.
`high model facial features, symmetrical features, well-proportioned figure, natural skin texture`
Monologue sync target: "{{hook_monologue}}" — seedance_2_0 lip-sync. {접미}

## main (ref=보드 Slot 2 크롭 + 인물앵커[Soul ID 또는 persona 마스터])
[보드 Slot 2 크롭 이미지를 레퍼런스로 사용]
{{model_desc}} holding {{product}} toward camera or demonstrating use — {{main_action_desc}}. Selfie POV, {{wardrobe_desc}}, {{location_desc}}, cool neutral daylight.
`high model facial features, symmetrical features, well-proportioned figure, natural skin texture`
Monologue sync target: "{{main_monologue}}" — seedance_2_0 lip-sync. {접미}

## closer (ref=보드 Slot 3 크롭 + 인물앵커[Soul ID 또는 persona 마스터])
[보드 Slot 3 크롭 이미지를 레퍼런스로 사용]
{{model_desc}} wrapping up with warm confident expression — {{closer_action_desc}}. Selfie POV, {{wardrobe_desc}}, {{location_desc}}, cool neutral daylight.
`high model facial features, symmetrical features, well-proportioned figure, natural skin texture`
Monologue sync target: "{{closer_monologue}}" — seedance_2_0 lip-sync. {접미}

## cta_tail (CTA 테일 — closer 말미 결합 또는 별도 1s 클립)
[closer 클립 말미 0.5~1초 또는 별도 short clip]
{{model_desc}} looking directly into camera, one hand pointing downward toward viewer ("Link in bio" gesture). Selfie POV, same wardrobe and location as closer.
Caption overlay (added in editly): "Link in bio" or "{{cta_text}}".
`high model facial features, symmetrical features, well-proportioned figure, natural skin texture`
seedance_2_0, no additional monologue (gesture only). {접미}
