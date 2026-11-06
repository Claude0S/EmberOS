#!/usr/bin/env python3
"""Ember OS theme assets: wallpaper + fox mascot for every theme.
Run: python3 tools/gen_assets.py OUTDIR   (needs rsvg-convert and ImageMagick)"""
import math, os, random, subprocess, sys, json

OUT = sys.argv[1] if len(sys.argv) > 1 else "out-assets"
W, H = 1920, 1080

THEMES = {
  "ember":  dict(name="Ember", accent="#e8875a", accent2="#f3a46c", accent3="#f2c37a", fg="#fbeee0", bg="#1a1320", surface="#523049",
                 sky=["#1d1730","#4a2c4f","#a8505a","#e2804e","#f4b77e"], glow=["#fff1d6","#ffd9a3","#f0955a"],
                 lake=["#f2a96f","#b85e57","#3e2742","#181222"], ridges=["#c98a8a","#8c5068","#523049"], land="#1a1222", trees="#160f1d", mist="#ffd6b0",
                 fox=dict(fur="#e8875a", chest="#fbeee0", eye="#2a1c26", nose="#2a1c26")),
  "night":  dict(name="Night", accent="#f39a5c", accent2="#c9a0dc", accent3="#f2c37a", fg="#ece6f2", bg="#100d16", surface="#2e2640",
                 sky=["#06050c","#120f24","#241c3e","#3a2c58","#5a4278"], glow=["#f4f0ff","#d8ccf2","#8a74b8"],
                 lake=["#5a4278","#2c2348","#141022","#08060e"], ridges=["#4a3c6a","#2e2548","#1a1530"], land="#0c0912", trees="#08060c", mist="#c9b8ea",
                 fox=dict(fur="#2f2838", chest="#bdb3cc", eye="#f39a5c", nose="#0e0b12", rim="#4a3d63")),
  "ocean":  dict(name="Ocean", accent="#5aa9e8", accent2="#7cc4e0", accent3="#9be0d8", fg="#e8f3fb", bg="#0f1824", surface="#2c4a66",
                 sky=["#0b1426","#16305a","#2f5f96","#5a9cd0","#a8d4ee"], glow=["#f0fbff","#c8ecff","#6ab4e8"],
                 lake=["#8ccbec","#3f7fb8","#1c3a5e","#0a1626"], ridges=["#6f9cc4","#3c6690","#22405e"], land="#0b1422", trees="#08101a", mist="#cfe9fa",
                 fox=dict(fur="#5aa9e8", chest="#e8f3fb", eye="#0f1824", nose="#0f1824")),
  "forest": dict(name="Forest", accent="#7cb96a", accent2="#a6d38c", accent3="#e3d27a", fg="#eef6e8", bg="#111a14", surface="#34503a",
                 sky=["#0f1a16","#1f3a2c","#3f6a46","#86a860","#e0d68a"], glow=["#fffbe0","#f2eba0","#b8c868"],
                 lake=["#c8cf86","#6e9a5c","#2c4a34","#0f1a14"], ridges=["#7ea06c","#4c7050","#2c4634"], land="#0e1810", trees="#0a120c", mist="#e4f0c8",
                 fox=dict(fur="#7cb96a", chest="#eef6e8", eye="#111a14", nose="#111a14")),
  "sakura": dict(name="Sakura", accent="#e8879f", accent2="#f3a6be", accent3="#f7c6d9", fg="#fdeef3", bg="#1c1220", surface="#5a3050",
                 sky=["#22142c","#4a2650","#9a4a7c","#e88aa8","#f8c8d8"], glow=["#fff2f6","#ffd2e2","#f08aac"],
                 lake=["#f2a8c0","#b85e86","#4a2848","#1a1020"], ridges=["#d08ab0","#9a5486","#5a3050"], land="#1c1022", trees="#160c1a", mist="#ffd8e6",
                 fox=dict(fur="#e8879f", chest="#fdeef3", eye="#2a1426", nose="#2a1426")),
  "mono":   dict(name="Mono", accent="#cfcfcf", accent2="#e6e6e6", accent3="#a8a8a8", fg="#f2f2f2", bg="#141414", surface="#3a3a3a",
                 sky=["#0c0c0c","#1e1e1e","#3a3a3a","#6a6a6a","#b4b4b4"], glow=["#ffffff","#e6e6e6","#9a9a9a"],
                 lake=["#bdbdbd","#6c6c6c","#2c2c2c","#0e0e0e"], ridges=["#8a8a8a","#5a5a5a","#363636"], land="#101010", trees="#0a0a0a", mist="#e8e8e8",
                 fox=dict(fur="#9a9a9a", chest="#f2f2f2", eye="#141414", nose="#141414")),
}

def wallpaper(t):
    random.seed(7)
    o=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}"><defs>']
    stops="".join(f'<stop offset="{off}" stop-color="{c}"/>' for off,c in zip([0,0.30,0.52,0.66,0.74],t["sky"]))
    o.append(f'<linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">{stops}</linearGradient>')
    g=t["glow"]
    o.append(f'<radialGradient id="sun" cx="1310" cy="560" r="520" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="{g[0]}"/><stop offset="0.12" stop-color="{g[1]}" stop-opacity="0.9"/><stop offset="0.4" stop-color="{g[2]}" stop-opacity="0.35"/><stop offset="1" stop-color="{g[2]}" stop-opacity="0"/></radialGradient>')
    l=t["lake"]
    o.append(f'<linearGradient id="lake" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{l[0]}"/><stop offset="0.25" stop-color="{l[1]}"/><stop offset="0.7" stop-color="{l[2]}"/><stop offset="1" stop-color="{l[3]}"/></linearGradient>')
    m=t["mist"]
    o.append(f'<linearGradient id="mist" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{m}" stop-opacity="0"/><stop offset="0.5" stop-color="{m}" stop-opacity="0.45"/><stop offset="1" stop-color="{m}" stop-opacity="0"/></linearGradient>')
    o.append('<filter id="glow" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="10" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter><filter id="blur8"><feGaussianBlur stdDeviation="8"/></filter><clipPath id="lakeclip"><rect x="0" y="760" width="1920" height="320"/></clipPath></defs>')
    o.append(f'<rect width="{W}" height="{H}" fill="url(#sky)"/>')
    for _ in range(140 if t is not THEMES["night"] else 260):
        x=random.uniform(0,W); y=random.uniform(0,380 if t is THEMES["night"] else 330)
        r=random.choice([0.6,0.8,1,1.2,1.6]); op=random.uniform(0.3,0.9)*(1-y/420)
        o.append(f'<circle cx="{x:.0f}" cy="{y:.0f}" r="{r}" fill="#fff8f0" opacity="{op:.2f}"/>')
    o.append(f'<rect width="{W}" height="{H}" fill="url(#sun)"/>')
    cx,cy,R=1310,520,62
    def star(x,y,s): return f'M{x},{y-s} Q{x+s*0.18},{y-s*0.18} {x+s},{y} Q{x+s*0.18},{y+s*0.18} {x},{y+s} Q{x-s*0.18},{y+s*0.18} {x-s},{y} Q{x-s*0.18},{y-s*0.18} {x},{y-s} Z'
    o.append(f'<circle cx="{cx}" cy="{cy}" r="95" fill="{g[0]}" opacity="0.55" filter="url(#blur8)"/>')
    o.append(f'<g filter="url(#glow)"><circle cx="{cx}" cy="{cy}" r="{R}" fill="none" stroke="{g[0]}" stroke-width="9"/><path d="{star(cx,cy,38)}" fill="{g[0]}"/></g>')
    def ridge(base,amp,rough,color,seed,op=1,step=12):
        random.seed(seed); pts=[]; phase=random.uniform(0,6)
        for x in range(-20,W+40,step):
            y=base-amp*(0.55*math.sin(x/260+phase)+0.3*math.sin(x/97+phase*2)+0.15*math.sin(x/41))+random.uniform(-rough,rough)
            pts.append(f'{x},{y:.1f}')
        return f'<path d="M-20,{H} L'+' L'.join(pts)+f' L{W+40},{H} Z" fill="{color}" opacity="{op}"/>'
    rg=t["ridges"]
    o.append(ridge(610,120,4,rg[0],3,0.75)); o.append(f'<rect x="0" y="560" width="{W}" height="120" fill="url(#mist)" filter="url(#blur8)"/>')
    o.append(ridge(660,95,6,rg[1],11)); o.append(f'<rect x="0" y="640" width="{W}" height="90" fill="url(#mist)" opacity="0.7" filter="url(#blur8)"/>')
    o.append(ridge(715,70,5,rg[2],21))
    o.append(f'<rect x="0" y="760" width="{W}" height="{H-760}" fill="url(#lake)"/>')
    o.append(f'<ellipse cx="1310" cy="900" rx="70" ry="140" fill="{g[1]}" opacity="0.35" filter="url(#blur8)" clip-path="url(#lakeclip)"/>')
    random.seed(5)
    for i in range(70):
        y=770+i*4.2+random.uniform(-2,2); w=random.uniform(20,160)*(1-(y-770)/400); x=1310+random.gauss(0,40)
        o.append(f'<rect x="{x-w/2:.0f}" y="{y:.0f}" width="{w:.0f}" height="1.6" rx="0.8" fill="{g[0]}" opacity="{random.uniform(0.25,0.7):.2f}"/>')
    for i in range(40):
        y=random.uniform(780,1060); w=random.uniform(40,220); x=random.uniform(0,W)
        o.append(f'<rect x="{x:.0f}" y="{y:.0f}" width="{w:.0f}" height="1.2" fill="{g[1]}" opacity="{random.uniform(0.05,0.2):.2f}"/>')
    def pine(x,base,h):
        w=h*0.32; s=''; s2=''
        for k in range(6):
            f=(k+1)/6; yy=base-h+h*f*0.92; ww=w*f; s+=f' L{x+ww:.1f},{yy:.1f} L{x+ww*0.35:.1f},{yy-h*0.04:.1f}'
        for k in reversed(range(6)):
            f=(k+1)/6; yy=base-h+h*f*0.92; ww=w*f; s2+=f' L{x-ww*0.35:.1f},{yy-h*0.04:.1f} L{x-ww:.1f},{yy:.1f}'
        return f'<path d="M{x},{base-h}{s} L{x+2},{base} L{x-2},{base}{s2} Z" fill="{t["trees"]}"/>'
    o.append(f'<path d="M0,740 Q200,730 420,770 Q520,790 560,{H} L0,{H} Z" fill="{t["land"]}"/>')
    o.append(f'<path d="M{W},720 Q1700,735 1560,775 Q1480,800 1460,{H} L{W},{H} Z" fill="{t["land"]}"/>')
    random.seed(9)
    for x in range(-10,520,22):
        o.append(pine(x+random.uniform(-6,6),760+(x/520)*25+random.uniform(-6,6),random.uniform(110,260)*(1-x/900)))
    for x in range(1500,W+20,22):
        o.append(pine(x+random.uniform(-6,6),760-((x-1500)/420)*25+random.uniform(-6,6),random.uniform(110,260)*(0.55+(x-1500)/900)))
    o.append('</svg>')
    return "\n".join(o)

HEAD=[".O..........O.",".OO........OO.",".OCO......OCO.",".OCOOOOOOOOCO.","OOOOOOOOOOOOOO",
      "OOOEEOOOOEEOOO","OOOEEOOOOEEOOO","CCOOOOOOOOOOCC",".CCCCOOOONCCCC.".replace("N","O")[:14],"..CCCCNNCCCC..","....CCCCCC...."]
def fox_grid():
    G={}
    def put(r,c,s):
        for i,ch in enumerate(s):
            if ch!='.': G[(r,c+i)]=ch
    for r,s in enumerate(HEAD): put(r,2,s)
    for r,(c,s) in {11:(5,"OOCCCCOO"),12:(4,"OOCCCCCCOO"),13:(3,"OOOCCCCCCOOO"),14:(3,"OOOCCCCCCOOO"),15:(3,"OOOOCCCCOOOO"),
                    16:(3,"OOOOOOOOOOOOO"),17:(3,"OOOOOOOOOOOOOO"),18:(3,"OCCCOOOOOOCCCO")}.items(): put(r,c,s)
    for r,(c,s) in {9:(18,"CC"),10:(17,"CCCC"),11:(17,"CCCC"),12:(17,"OOOO"),13:(17,"OOOO"),14:(16,"OOOO"),15:(15,"OOOO"),16:(15,"OOO")}.items(): put(r,c,s)
    return G

def fox_svg(t, bg):
    f=t["fox"]; G=fox_grid(); col={'O':f["fur"],'C':f["chest"],'E':f["eye"],'N':f["nose"]}
    rows=max(r for r,_ in G)+1; cols=max(c for _,c in G)+1
    S=1024; px=40; ox=(S-cols*px)//2; oy=(S-rows*px)//2+10
    o=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{S}" height="{S}" shape-rendering="crispEdges">']
    if bg:
        o.append(f'<defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{t["sky"][0]}"/><stop offset="0.6" stop-color="{t["sky"][2]}"/><stop offset="1" stop-color="{t["sky"][3]}"/></linearGradient></defs>')
        o.append(f'<rect width="{S}" height="{S}" fill="url(#g)"/>')
        random.seed(3)
        for _ in range(40):
            o.append(f'<rect x="{random.randrange(0,S,8)}" y="{random.randrange(0,420,8)}" width="8" height="8" fill="#fff8f0" opacity="{random.uniform(.3,.8):.2f}"/>')
        o.append(f'<rect x="{ox+2*px}" y="{oy+rows*px}" width="{14*px}" height="{px//2}" fill="#000" opacity="0.25"/>')
    if "rim" in f:   # dark fox: soft outline so it stays visible on dark backgrounds
        for (r,c) in G:
            for dr,dc in ((-1,0),(1,0),(0,-1),(0,1)):
                if (r+dr,c+dc) not in G:
                    o.append(f'<rect x="{ox+(c+dc)*px}" y="{oy+(r+dr)*px}" width="{px}" height="{px}" fill="{f["rim"]}"/>')
    for (r,c),ch in G.items():
        o.append(f'<rect x="{ox+c*px}" y="{oy+r*px}" width="{px}" height="{px}" fill="{col[ch]}"/>')
        if ch=='E' and "rim" in f:
            o.append(f'<rect x="{ox+c*px-6}" y="{oy+r*px-6}" width="{px+12}" height="{px+12}" fill="{f["eye"]}" opacity="0.25"/>')
    o.append('</svg>'); return "\n".join(o)

def run(*a): subprocess.run(a, check=True)

os.makedirs(OUT, exist_ok=True)
for key,t in THEMES.items():
    d=os.path.join(OUT,key); os.makedirs(d,exist_ok=True)
    open(f"{d}/wallpaper.svg","w").write(wallpaper(t)); run("rsvg-convert","-w","1920","-h","1080",f"{d}/wallpaper.svg","-o",f"{d}/wallpaper.png"); os.remove(f"{d}/wallpaper.svg")
    open(f"{d}/fox.svg","w").write(fox_svg(t,False)); run("rsvg-convert",f"{d}/fox.svg","-o",f"{d}/fox.png")
    open(f"{d}/fox-avatar.svg","w").write(fox_svg(t,True)); run("rsvg-convert",f"{d}/fox-avatar.svg","-o",f"{d}/fox-avatar.png")
    os.remove(f"{d}/fox-avatar.svg")
    run("convert",f"{d}/fox.png","-trim","+repage","-filter","point","-resize","220x220",f"{d}/fox-small.png")
    os.remove(f"{d}/fox.svg")
    pal={k:t[k] for k in ("name","accent","accent2","accent3","fg","bg","surface")}
    pal["fox"]=t["fox"]
    json.dump(pal, open(f"{d}/theme.json","w"), indent=2)
print("done:", ", ".join(THEMES))
