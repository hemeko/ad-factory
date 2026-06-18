# 샷별 프롬프트 템플릿
공통 접미: `Photorealistic vertical 9:16, authentic UGC influencer smartphone photo, natural cohesive lighting, realistic skin, anatomically correct hands — natural proportions, no extra hands or fingers, no visible camera rig, no text, no watermark.`

## master
Use the FIRST reference for body pose / camera angle / framing. Use ONLY the {{condition}} texture pattern from the SECOND reference (not its skin tone). A {{model}} seen {{framing}}, {{wardrobe}}, in {{location}}. The {{area}} skin clearly shows {{condition}} ({{condition_detail}}). {접미}

## day_reveal (ref=마스터 또는 직전 깨끗 프레임)
Use this image as the only reference. Keep the SAME person, arm, pose, camera framing. Change only: skin on {{area}} = {{skin_level}}; setting/light = {{location_day}} ({{light_day}}). {접미}

## gommage (ref=해당 day 리빌, +텍스처 ref)
Use the FIRST reference for person/arm/location/skin level. Use the SECOND as gommage texture: fine DISTINCT white particles/flakes over glistening skin (not grey, not a thick film). Other hand rolling {{product}} on the {{roll_area}}, abundant white gommage spread. {접미}

## squeeze (ref=마스터/바르는포즈, +제품컷)
Use the FIRST reference for person/arm/location. Use the SECOND for the exact product (keep label accurate). Squeeze the tube at a natural 3/4 angle, a SMALL amount of {{texture_desc}} balm onto her {{area}} (matches real texture, not runny). {접미}

## payoff (ref=가장 깨끗한 직전 프레임)
Use this image as the only reference. Keep person/arm/pose/framing. Skin = fully smooth, even, healthy natural dewy glow (keep pores, NOT plastic/oily). Setting {{location_payoff}}. {접미}
