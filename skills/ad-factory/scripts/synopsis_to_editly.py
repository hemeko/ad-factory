#!/usr/bin/env python3
"""synopsis.yaml + 자막맵(JSON) → editly 스펙(JSON).
컷=clip(video+title), 트랜지션 기본 cut(하드컷), 엔드카드=image+title, bgm optional.
prepped 클립(prepped_0.mp4...)은 synopsis의 video 컷 순서와 1:1 매핑.

자막 스타일: captions.json 최상위 "_style"(전역 기본) + 각 캡션 항목별 오버라이드 지원.
  지원 키: textColor(예 "#FFFFFF"), fontPath(repo-relative TTF/OTF, Docker /data 기준), fontSize(0~1 캔버스폭 비율).
  fontPath는 editly Docker 컨테이너(/data 마운트)에서 보이는 repo-relative 경로여야 함.
Usage: synopsis_to_editly.py --synopsis s.yaml --prepped DIR --captions caps.json --out spec.json [--bgm PATH] [--outpath FINAL.mp4] [--transition cut|fade]"""
import argparse, json, yaml, os, glob, sys

STYLE_KEYS = ("textColor", "fontPath", "fontSize")

def title_layer(text, position, style):
    L = {"type": "title", "text": text, "position": position}
    for k in STYLE_KEYS:
        if style.get(k) is not None:
            L[k] = style[k]
    return L

def main():
    ap = argparse.ArgumentParser()
    for x in ["synopsis", "prepped", "captions", "out"]: ap.add_argument("--" + x, required=True)
    ap.add_argument("--bgm", default=""); ap.add_argument("--outpath", default="output/FINAL_ad.mp4")
    ap.add_argument("--width", type=int, default=1080); ap.add_argument("--height", type=int, default=1920); ap.add_argument("--fps", type=int, default=24)
    ap.add_argument("--transition", choices=["cut", "fade"], default="cut",
                    help="컷 간 트랜지션: cut=하드컷(기본, UGC 진정성), fade=페이드 0.3s")
    ap.add_argument("--keep-audio", action="store_true",
                    help="클립 원본 오디오 유지(토킹헤드 보이스 등). editly keepSourceAudio=true.")
    a = ap.parse_args()
    syn = yaml.safe_load(open(a.synopsis)); caps = json.load(open(a.captions))
    gstyle = caps.get("_style", {})  # 전역 자막 스타일
    prepped = sorted(glob.glob(os.path.join(a.prepped, "prepped_*.mp4")),
                     key=lambda p: int(os.path.basename(p).split("_")[1].split(".")[0]))
    proj_dir = os.path.dirname(os.path.normpath(a.prepped))  # 프로젝트 루트(prepped의 부모)
    def resolve_img(p):  # repo-relative(projects/...) 또는 절대경로면 그대로, 아니면 프로젝트 루트 기준
        return p if (os.path.isabs(p) or p.startswith("projects/")) else os.path.join(proj_dir, p)
    def add_caption(layers, ck):
        if ck and ck in caps:
            cap = caps[ck]
            style = {**gstyle, **{k: cap[k] for k in STYLE_KEYS if k in cap}}  # 캡션별 오버라이드
            layers.append(title_layer(cap["text"], cap.get("position", "top"), style))
    clips = []; vi = 0
    for cut in syn["cuts"]:
        cid = cut.get("id")
        if cid == "endcard":  # 제품 엔드카드: image + 켄번스 줌 + text 배열
            layers = [{"type": "image", "path": resolve_img(cut["image"]),
                       "zoomDirection": "in", "zoomAmount": 0.1}]
            texts = cut.get("text", [])
            n = len(texts)
            base_fs = gstyle.get("fontSize", 0.045)
            for i, t in enumerate(texts):
                # 긴 자막 자동 축소(wrap·겹침 방지): 14자 초과 시 길이에 반비례로 줄임
                fs = base_fs if len(t) <= 14 else round(base_fs * 14 / len(t), 4)
                pos = "bottom" if n == 1 else {"x": 0.5, "y": round(0.74 + i * 0.10, 4), "originX": "center", "originY": "center"}
                layers.append(title_layer(t, pos, {**gstyle, "fontSize": fs}))
            clips.append({"duration": cut.get("duration", 3), "layers": layers}); continue
        img = cut.get("image") or (cut.get("frames") or {}).get("image")
        if cut.get("type") == "image_insert" or img:  # before/after 등 무음 이미지 인서트
            layers = [{"type": "image", "path": resolve_img(img)}]
            add_caption(layers, cut.get("caption"))
            clips.append({"duration": cut.get("duration", 2), "layers": layers}); continue
        layers = [{"type": "video", "path": prepped[vi]}]; vi += 1  # 토킹헤드/액션 클립
        add_caption(layers, cut.get("caption"))
        clips.append({"layers": layers})
    transition_val = None if a.transition == "cut" else {"name": "fade", "duration": 0.3}
    spec = {"outPath": a.outpath, "width": a.width, "height": a.height, "fps": a.fps,
            "defaults": {"transition": transition_val}, "clips": clips}
    if a.bgm: spec["audioFilePath"] = a.bgm
    if a.keep_audio: spec["keepSourceAudio"] = True
    json.dump(spec, open(a.out, "w"), indent=2, ensure_ascii=False); print(a.out)
if __name__ == "__main__": sys.exit(main())
