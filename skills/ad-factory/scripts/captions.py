#!/usr/bin/env python3
"""caption 맵(JSON) → 전체프레임 투명 자막 PNG들(ImageMagick).
Usage: captions.py --captions caps.json --out DIR [--w 1080 --h 1920 --font PATH]
caps.json: {"hook":{"text":"...","position":"top"}, "DAY 1":{...,"position":"top-left"}, ...}"""
import argparse, json, subprocess, sys, os
FONT="/System/Library/Fonts/Supplemental/Arial Bold.ttf"
GRAV={"top":("North","+0+%d",150,66),"top-left":("NorthWest","+60+%d",110,92),"bottom":("South","+0+%d",240,58)}
def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--captions",required=True); ap.add_argument("--out",required=True)
    ap.add_argument("--w",type=int,default=1080); ap.add_argument("--h",type=int,default=1920); ap.add_argument("--font",default=FONT)
    a=ap.parse_args(); caps=json.load(open(a.captions)); os.makedirs(a.out,exist_ok=True)
    for cid,c in caps.items():
        grav,xyf,off,size=GRAV.get(c.get("position","top"),GRAV["top"])
        outp=os.path.join(a.out, cid.replace(" ","_")+".png")
        subprocess.run(["magick","-size",f"{a.w}x{a.h}","xc:none","-font",a.font,"-pointsize",str(size),
            "-fill","white","-undercolor","#00000066","-gravity",grav,"-annotate",xyf%off," %s "%c["text"],outp],check=True)
        print(outp)
if __name__=="__main__": sys.exit(main())
