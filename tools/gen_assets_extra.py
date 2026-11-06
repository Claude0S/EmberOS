#!/usr/bin/env python3
"""Six extra Ember OS themes (aurora, cyber, autumn, desert, winter, cosmos):
scene overlays + mascot variants on top of gen_assets.py.
Run: python3 tools/gen_assets_extra.py OUTDIR
     python3 tools/gen_assets_extra.py --heads THEMESDIR   (only head.json for the terminal banner)"""
import math, random, re, sys, os, subprocess, json
src=open(os.path.join(os.path.dirname(os.path.abspath(__file__)),"gen_assets.py")).read()
src=src.split("def run(*a)")[0]
OUTARG=sys.argv[1] if len(sys.argv)>1 else "out-assets"; sys.argv_heads=sys.argv[2] if len(sys.argv)>2 else ""; sys.argv=["x",OUTARG]
exec(src)
W,H=1920,1080

NEW = {
 "aurora": dict(name="Aurora", accent="#5fe0c0", accent2="#8fb8ff", accent3="#c3f5e6", fg="#eaf6f8", bg="#0a1218", surface="#1f3a48",
   sky=["#03070f","#071a2a","#0e3346","#1c5a6a","#4a8e98"], glow=["#f4fbff","#cfeaff","#6ab4d8"],
   lake=["#4a8e98","#1c4a5a","#0b2230","#050c12"], ridges=["#5a7e90","#2e4c60","#16303e"], land="#081218", trees="#050b10", mist="#bfe8f0",
   fox=dict(fur="#e6eef2", chest="#ffffff", eye="#16303e", nose="#16303e", rim="#7fb6c8"), fx=["aurora","snowcaps"], mascot="arctic"),
 "cyber": dict(name="Cyber", accent="#ff4fa3", accent2="#4fe3ff", accent3="#b98bff", fg="#f3ecff", bg="#0d0818", surface="#33204f",
   sky=["#07040f","#1a0b33","#3b1260","#8a1f7a","#ff6a8a"], glow=["#fff0fa","#ff9ad0","#ff4fa3"],
   lake=["#ff6a8a","#6a1a6a","#1e0b33","#07040f"], ridges=["#5a2a80","#3a1a5a","#24103e"], land="#0d0818", trees="none", mist="#ff9ad0",
   fox=dict(fur="#2c2240", chest="#d9c8ff", eye="#4fe3ff", nose="#120b20", rim="#ff4fa3", V="#4fe3ff"), fx=["city","grid"], mascot="visor"),
 "autumn": dict(name="Autumn", accent="#e0693a", accent2="#f0a03c", accent3="#f5d27a", fg="#fbefe2", bg="#1a110c", surface="#4e2e1e",
   sky=["#2a1a22","#5a2e30","#b05a3a","#e8964a","#f6d08a"], glow=["#fff4dc","#ffd890","#e8803a"],
   lake=["#f0a860","#a8502e","#3e2218","#170e0a"], ridges=["#b8704a","#8a4a32","#5a3020"], land="#1a0f0a", trees="#3a160c", mist="#ffd8a8",
   fox=dict(fur="#d9622e", chest="#fbefe2", eye="#2a160e", nose="#2a160e", S="#8a2a3a", s="#b8404e"), fx=["leaves"], mascot="scarf"),
 "desert": dict(name="Desert", accent="#e6a352", accent2="#f2c27a", accent3="#7fc8c0", fg="#fbf1e0", bg="#1c140c", surface="#5a3e26",
   sky=["#1c1a3a","#3e3a6a","#b0708a","#f0a870","#ffe0a8"], glow=["#fffaf0","#ffe8b8","#f0a860"],
   lake=["#f2c27a","#c08048","#7a4a2a","#2a1a10"], ridges=["#c88a6a","#a0644a","#7a4a34"], land="#b8784a", trees="none", mist="#ffe0b8",
   fox=dict(fur="#e8c08a", chest="#fbf1e0", eye="#2a1a10", nose="#2a1a10", P="#d89a8a"), fx=["dunes"], mascot="fennec"),
 "winter": dict(name="Winter", accent="#7fb2e8", accent2="#c8a8f0", accent3="#e8f2ff", fg="#f2f6fc", bg="#10141e", surface="#34405a",
   sky=["#141a2c","#2a3654","#5a6c94","#a8b8d8","#e8eef8"], glow=["#ffffff","#eef4ff","#a8c4e8"],
   lake=["#d8e4f4","#8aa0c4","#3a4a6a","#141a28"], ridges=["#e8eef8","#b8c6e0","#7a8cb0"], land="#e6edf7", trees="#24304a", mist="#ffffff",
   fox=dict(fur="#e8875a", chest="#fbeee0", eye="#2a1c26", nose="#2a1c26", K="#c83a4a", k="#f2f2f2"), fx=["snow"], mascot="hat"),
 "cosmos": dict(name="Cosmos", accent="#9a7cff", accent2="#ff9ad8", accent3="#7ce0ff", fg="#eeeaff", bg="#08061a", surface="#2a2458",
   sky=["#020110","#0a0626","#1e1450","#3a2280","#6a3aa0"], glow=["#fff8ff","#e0c8ff","#9a7cff"],
   lake=["#6a3aa0","#2a1a5a","#100a2a","#04020c"], ridges=["#3a2e70","#241c50","#140f34"], land="#06040f", trees="none", mist="#c8b0ff",
   fox=dict(fur="#e8875a", chest="#fbeee0", eye="#2a1c26", nose="#2a1c26", R="#c8d8ff", r="#ffffff"), fx=["planets","nebula"], mascot="helmet"),
}

def overlay_back(t):
    o=[]; fx=t["fx"]
    if "aurora" in fx:
        o.append('<defs><filter id="ab" x="-20%" y="-50%" width="140%" height="200%"><feGaussianBlur stdDeviation="22"/></filter><linearGradient id="au" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#7cf0c8" stop-opacity="0"/><stop offset="0.6" stop-color="#5fe0c0" stop-opacity="0.75"/><stop offset="1" stop-color="#8fb8ff" stop-opacity="0"/></linearGradient></defs>')
        for k,(y,a,c) in enumerate([(160,90,"url(#au)"),(240,70,"url(#au)"),(110,60,"#b38cff")]):
            pts=" ".join(f"L{x},{y+a*math.sin(x/230+k*1.7)+30*math.sin(x/90+k):.0f}" for x in range(0,W+60,40))
            pts2=" ".join(f"L{x},{y+260+a*math.sin(x/230+k*1.7)+30*math.sin(x/90+k):.0f}" for x in range(W+20,-60,-40))
            o.append(f'<path d="M0,{y} {pts} {pts2} Z" fill="{c}" opacity="{0.8 if k<2 else 0.35}" filter="url(#ab)"/>')
    if "nebula" in fx:
        for k,(cx,cy,r,c,op) in enumerate([(500,250,330,"#ff6ad0",0.38),(820,170,280,"#6a8cff",0.34),(1600,300,380,"#9a5aff",0.32)]):
            o.append(f'<defs><radialGradient id="nb{k}"><stop offset="0" stop-color="{c}" stop-opacity="{op}"/><stop offset="1" stop-color="{c}" stop-opacity="0"/></radialGradient></defs><circle cx="{cx}" cy="{cy}" r="{r}" fill="url(#nb{k})"/>')
        random.seed(13)
        for _ in range(220):
            o.append(f'<circle cx="{random.uniform(0,W):.0f}" cy="{random.uniform(0,600):.0f}" r="{random.choice([0.6,0.9,1.3,1.8])}" fill="#ffffff" opacity="{random.uniform(.3,.95):.2f}"/>')
    if "planets" in fx:
        o.append('<defs><radialGradient id="pl" cx="0.35" cy="0.35" r="0.7"><stop offset="0" stop-color="#ffc0e8"/><stop offset="0.6" stop-color="#9a5ac8"/><stop offset="1" stop-color="#2a1458"/></radialGradient><radialGradient id="pl2" cx="0.3" cy="0.3" r="0.8"><stop offset="0" stop-color="#bff0ff"/><stop offset="1" stop-color="#2a4a9a"/></radialGradient></defs>')
        o.append('<circle cx="430" cy="300" r="120" fill="url(#pl)"/><ellipse cx="430" cy="300" rx="215" ry="38" fill="none" stroke="#ffd0f0" stroke-width="7" opacity="0.7" transform="rotate(-18 430 300)"/>')
        o.append('<circle cx="1700" cy="170" r="42" fill="url(#pl2)"/>')
    if "city" in fx:
        random.seed(4); x=-10
        while x<W:
            w=random.randint(40,110); h=random.randint(80,330)
            if 1150<x<1480: h=random.randint(60,140)
            o.append(f'<rect x="{x}" y="{760-h}" width="{w}" height="{h}" fill="#140a26"/>')
            for wy in range(760-h+12,750,18):
                for wx in range(x+8,x+w-8,14):
                    if random.random()<0.28:
                        o.append(f'<rect x="{wx}" y="{wy}" width="6" height="8" fill="{random.choice(["#ff4fa3","#4fe3ff","#ffd0f0"])}" opacity="{random.uniform(.5,.95):.2f}"/>')
            if random.random()<0.25: o.append(f'<rect x="{x}" y="{760-h}" width="{w}" height="3" fill="#4fe3ff" opacity="0.8"/>')
            x+=w+random.randint(2,10)
    return "\n".join(o)

def dunes(t):
    o=[]
    if True:
        for y,c,ph in [(880,"#c88a5a",0.3),(950,"#a8683e",1.6),(1010,"#8a5030",2.4),(1060,"#6a3a22",4.0)]:
            pts=" ".join(f"L{x},{y-60*math.sin(x/380+ph)-25*math.sin(x/150+ph*2):.0f}" for x in range(0,W+40,20))
            o.append(f'<path d="M0,{H} {pts} L{W},{H} Z" fill="{c}"/>')
        for x0,h in [(700,150),(1760,110)]:
            o.append(f'<rect x="{x0}" y="{1000-h}" width="18" height="{h}" rx="9" fill="#2e3a22"/><rect x="{x0-34}" y="{960-h*0.6:.0f}" width="14" height="{h*0.35:.0f}" rx="7" fill="#2e3a22"/><rect x="{x0-34}" y="{960-h*0.6+h*0.35-14:.0f}" width="40" height="14" rx="7" fill="#2e3a22"/><rect x="{x0+30}" y="{970-h*0.75:.0f}" width="14" height="{h*0.3:.0f}" rx="7" fill="#2e3a22"/><rect x="{x0+10}" y="{970-h*0.75+h*0.3-14:.0f}" width="34" height="14" rx="7" fill="#2e3a22"/>')
    return "\n".join(o)

def overlay_front(t):
    o=[]; fx=t["fx"]
    if "dunes" in fx: o.append(dunes(t))
    if "grid" in fx:
        for i in range(14):
            y=780+ (i**1.7)*1.9
            o.append(f'<rect x="0" y="{y:.0f}" width="{W}" height="2" fill="#ff4fa3" opacity="{0.15+i*0.04:.2f}"/>')
        for k in range(-24,25):
            o.append(f'<line x1="{1310+k*20}" y1="780" x2="{1310+k*260}" y2="{H}" stroke="#4fe3ff" stroke-width="1.5" opacity="0.35"/>')
    if "snow" in fx or "snowcaps" in fx:
        random.seed(21); n=420 if "snow" in fx else 0
        for _ in range(n):
            o.append(f'<circle cx="{random.uniform(0,W):.0f}" cy="{random.uniform(0,H):.0f}" r="{random.choice([1.2,1.8,2.4,3.2])}" fill="#ffffff" opacity="{random.uniform(.4,.95):.2f}"/>')
    if "leaves" in fx:
        random.seed(31)
        for _ in range(70):
            x=random.uniform(0,W); y=random.uniform(0,H); s=random.uniform(6,16); a=random.uniform(0,360)
            c=random.choice(["#e0693a","#f0a03c","#c8402e","#f5d27a"])
            o.append(f'<ellipse cx="{x:.0f}" cy="{y:.0f}" rx="{s:.1f}" ry="{s*0.45:.1f}" fill="{c}" opacity="{random.uniform(.5,.9):.2f}" transform="rotate({a:.0f} {x:.0f} {y:.0f})"/>')
    return "\n".join(o)

def wallpaper_x(t):
    s=wallpaper(t)
    if t["trees"]=="none": s=s.replace('fill="none"/>','fill="none"/>')  # pines invisible
    sky='<rect width="1920" height="1080" fill="url(#sky)"/>'
    s=s.replace(sky, sky+"\n"+overlay_back(t) if "city" not in t["fx"] else sky, 1)
    extra=""
    if "city" in t["fx"]:
        # city/dunes go in front of mountains but behind lake: insert before lake rect
        i=s.rfind('<rect',0,s.index('fill="url(#lake)"/>')); s=s[:i]+overlay_back(t)+"\n"+s[i:]
    s=s.replace("</svg>", overlay_front(t)+"\n</svg>")
    return s

def grid_x(kind, normalize=True):
    G=fox_grid()
    def put(r,c,ch): G[(r,c)]=ch
    if kind=="fennec":
        ear={-4:[3],-3:[2,3,4],-2:[2,3,4,5],-1:[1,2,3,4,5],0:[1,2,3,4,5,6],1:[1,2,3,4,5,6]}
        pink={-2:[3,4],-1:[3,4],0:[3,4,5],1:[4,5]}
        for r,cols in ear.items():
            for c in cols: put(r,c,'O'); put(r,17-c,'O')
        for r,cols in pink.items():
            for c in cols: put(r,c,'P'); put(r,17-c,'P')
    if kind=="hat":
        for c in range(4,14): put(1,c,'K'); put(0,c,'K')
        for c in range(5,13): put(-1,c,'K')
        for c in range(4,14): put(2,c,'k')
        for c in (8,9): put(-2,c,'k'); put(-3,c,'k')
    if kind=="scarf":
        for c in range(4,16): put(10,c,'S')
        for c in range(5,15): put(11,c,'s' if c%2 else 'S')
        for r in (12,13,14): put(r,12,'S'); put(r,13,'s')
    if kind=="visor":
        for c in range(3,15): put(5,c,'V'); put(6,c,'V')
    if kind=="helmet":
        cy,cx=5.5,9.0
        for r in range(-6,17):
            for c in range(-4,22):
                d=math.hypot(r-cy,(c-cx))
                if 9.6<=d<10.6: G.setdefault((r,c),'R')
        for (r,c) in [(-1,4),(0,3),(1,3)]: G[(r,c)]='r'
    if not normalize: return G
    mr=min(r for r,_ in G); mc=min(c for _,c in G)
    return {(r-mr,c-mc):v for (r,c),v in G.items()}

def head_json(t, kind):
    """Head of the mascot (with its hat/visor/ears) for the terminal banner."""
    f=t["fox"]; G=grid_x(kind, normalize=False)
    H={(r,c):v for (r,c),v in G.items() if r<=11 and 1<=c<=16 and not (r>=9 and c>=16)}
    if kind!="scarf": H={k:v for k,v in H.items() if k[0]<=10}
    if kind=="helmet":   # full round glass helmet around the head only
        base=fox_grid()
        H={k:(base[k] if v in "Rr" else v) for k,v in H.items() if v not in "Rr" or k in base}
        for r in range(-5,16):
            for c in range(-2,20):
                d=math.hypot(r-5.0,c-8.5)
                if 8.0<=d<9.0 and (r,c) not in H: H[(r,c)]='R'
        for rc in [(-1,5),(-1,4),(0,2)]: H[rc]="r"

    col={'O':f["fur"],'C':f["chest"],'E':f["eye"],'N':f["nose"]}
    col.update({k:v for k,v in f.items() if len(k)==1})
    if "rim" in f:
        col['m']=f["rim"]
        for (r,c),v in list(H.items()):
            if v in "RrV": continue
            for dr,dc in ((-1,0),(1,0),(0,-1),(0,1)):
                if (r+dr,c+dc) not in H: H[(r+dr,c+dc)]='m'
    r0=min(r for r,_ in H); r1=max(r for r,_ in H); c0=min(c for _,c in H); c1=max(c for _,c in H)
    rows=["".join(H.get((r,c),'.') for c in range(c0,c1+1)) for r in range(r0,r1+1)]
    used={ch for row in rows for ch in row if ch!='.'}
    return {"rows":rows,"colors":{k:v for k,v in col.items() if k in used}}

def fox_svg_x(t,bg):
    f=t["fox"]; G=grid_x(t["mascot"])
    col={'O':f["fur"],'C':f["chest"],'E':f["eye"],'N':f["nose"]}
    col.update({k:v for k,v in f.items() if len(k)==1})
    rows=max(r for r,_ in G)+1; cols=max(c for _,c in G)+1
    S=1024; px=min(40, int(900/max(rows,cols))); ox=(S-cols*px)//2; oy=(S-rows*px)//2+10
    o=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{S}" height="{S}" shape-rendering="crispEdges">']
    if bg:
        o.append(f'<defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{t["sky"][0]}"/><stop offset="0.6" stop-color="{t["sky"][2]}"/><stop offset="1" stop-color="{t["sky"][3]}"/></linearGradient></defs><rect width="{S}" height="{S}" fill="url(#g)"/>')
        random.seed(3)
        for _ in range(40):
            o.append(f'<rect x="{random.randrange(0,S,8)}" y="{random.randrange(0,420,8)}" width="8" height="8" fill="#fff8f0" opacity="{random.uniform(.3,.8):.2f}"/>')
    if "rim" in f:
        for (r,c),ch in list(G.items()):
            if ch in "RrV": continue
            for dr,dc in ((-1,0),(1,0),(0,-1),(0,1)):
                if (r+dr,c+dc) not in G:
                    o.append(f'<rect x="{ox+(c+dc)*px}" y="{oy+(r+dr)*px}" width="{px}" height="{px}" fill="{f["rim"]}"/>')
    if t["mascot"]=="helmet":
        o.append(f'<circle cx="{ox+9.5*px+px/2-px/2}" cy="{oy+(5.5+6)*px+px/2}" r="{10*px}" fill="#bcd0ff" opacity="0.12"/>')
    for (r,c),ch in G.items():
        op=' opacity="0.85"' if ch=='R' else ''
        o.append(f'<rect x="{ox+c*px}" y="{oy+r*px}" width="{px}" height="{px}" fill="{col[ch]}"{op}/>')
        if ch=='V':
            o.append(f'<rect x="{ox+c*px-4}" y="{oy+r*px-4}" width="{px+8}" height="{px+8}" fill="{col["V"]}" opacity="0.2"/>')
    o.append('</svg>'); return "\n".join(o)

def run(*a): subprocess.run(a, check=True)

def write_heads(themes_dir):
    for key,t in list(THEMES.items())+list(NEW.items()):
        d=os.path.join(themes_dir,key)
        if os.path.isdir(d):
            json.dump(head_json(t, t.get("mascot","plain")), open(f"{d}/head.json","w"))

if OUTARG=="--heads":
    write_heads(sys.argv_heads); print("heads ok"); sys.exit(0)
OUT=OUTARG; os.makedirs(OUT,exist_ok=True)
for key,t in NEW.items():
    d=os.path.join(OUT,key); os.makedirs(d,exist_ok=True)
    tt=dict(t)
    open(f"{d}/wallpaper.svg","w").write(wallpaper_x(tt)); run("rsvg-convert","-w","1920","-h","1080",f"{d}/wallpaper.svg","-o",f"{d}/wallpaper.png")
    open(f"{d}/fox.svg","w").write(fox_svg_x(tt,False)); run("rsvg-convert",f"{d}/fox.svg","-o",f"{d}/fox.png")
    open(f"{d}/fox-avatar.svg","w").write(fox_svg_x(tt,True)); run("rsvg-convert",f"{d}/fox-avatar.svg","-o",f"{d}/fox-avatar.png")
    run("convert",f"{d}/fox.png","-trim","+repage","-filter","point","-resize","220x220",f"{d}/fox-small.png")
    pal={k:t[k] for k in ("name","accent","accent2","accent3","fg","bg","surface")}; pal["fox"]={k:v for k,v in t["fox"].items()}
    json.dump(pal,open(f"{d}/theme.json","w"),indent=2)
write_heads(OUT)
print("ok")
