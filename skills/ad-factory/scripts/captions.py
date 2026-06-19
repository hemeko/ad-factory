#!/usr/bin/env python3
"""caption 맵(JSON) → 전체프레임 투명 자막 PNG들(ImageMagick).
색·언더컬러·폰트는 **캡션별 > CLI 인자 > _style > 기본** 순. 흰색은 고정이 아니라 기본값일 뿐.
ad-editor가 브랜드·배경 대비에 맞게 textColor/underColor를 captions.json에 지정(전역 _style 또는 캡션별).
Usage: captions.py --captions caps.json --out DIR [--w 1080 --h 1920 --font PATH --fill COLOR --undercolor COLOR]
caps.json 예: {"_style":{"textColor":"#FFFFFF","underColor":"#00000066","fontPath":"..."},
               "hook":{"text":"...","position":"top","textColor":"#FFD700","underColor":"none"}, ...}
  underColor "none" = 배경 박스 끔(외곽선/대비색만으로 가독성 확보 시)."""
import argparse, json, subprocess, sys, os
FONT="/System/Library/Fonts/Supplemental/Arial Bold.ttf"
GRAV={"top":("North","+0+%d",150,66),"top-left":("NorthWest","+60+%d",110,92),"bottom":("South","+0+%d",240,58)}
def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--captions",required=True); ap.add_argument("--out",required=True)
    ap.add_argument("--w",type=int,default=1080); ap.add_argument("--h",type=int,default=1920); ap.add_argument("--font",default=FONT)
    ap.add_argument("--fill",default=None); ap.add_argument("--undercolor",default=None)
    a=ap.parse_args(); caps=json.load(open(a.captions)); os.makedirs(a.out,exist_ok=True)
    style=caps.get("_style",{})  # 전역 자막 스타일(synopsis_to_editly와 공유)
    for cid,c in caps.items():
        if cid=="_style": continue  # _style은 스타일 키지 캡션이 아님
        grav,xyf,off,size=GRAV.get(c.get("position","top"),GRAV["top"])
        outp=os.path.join(a.out, cid.replace(" ","_")+".png")
        # 우선순위: 캡션별 > CLI > _style > 기본(흰색/반투명 검정 — 가독성 안전값)
        fill  = c.get("textColor")  or a.fill       or style.get("textColor")  or "white"
        under = c.get("underColor") or a.undercolor or style.get("underColor") or "#00000066"
        font  = c.get("fontPath")   or style.get("fontPath") or a.font
        subprocess.run(["magick","-size",f"{a.w}x{a.h}","xc:none","-font",font,"-pointsize",str(size),
            "-fill",fill,"-undercolor",under,"-gravity",grav,"-annotate",xyf%off," %s "%c["text"],outp],check=True)
        print(outp)
if __name__=="__main__": sys.exit(main())
