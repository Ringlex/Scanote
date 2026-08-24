"""Składa grafikę promocyjną 1024x500 do ../en-US/graphics.

    python3 feature.py          # wymaga Pillow i Google Chrome
"""
import base64, os, subprocess
from PIL import Image

S = os.path.dirname(os.path.abspath(__file__))
RAW, BUILD, FONTS = f"{S}/raw", f"{S}/build", f"{S}/fonts"
OUT = f"{S}/../en-US/graphics/feature-graphic-1024x500.png"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
os.makedirs(BUILD, exist_ok=True)
os.makedirs(os.path.dirname(OUT), exist_ok=True)

def b64(p):
    return base64.b64encode(open(p, "rb").read()).decode()

FONT_FACES = "".join(
    f"@font-face{{font-family:'Changa';font-weight:{w};font-style:normal;"
    f"src:url(data:font/ttf;base64,{b64(f'{FONTS}/changa-{i}.ttf')}) format('truetype');}}"
    for i, w in ((1, 400), (2, 600), (3, 700))
)

# kartka bez zbędnego biurka dookoła, i ekran checklisty bez pasków systemowych
Image.open(f"{S}/paper-list.png").convert("RGB").crop((110, 130, 1090, 1470)).save(f"{BUILD}/paper.png")
Image.open(f"{RAW}/03-checklist.png").convert("RGB").crop((0, 115, 1080, 2268)).save(f"{BUILD}/screen.png")

html = f"""<!doctype html><html><head><meta charset="utf-8"><style>
{FONT_FACES}
*{{margin:0;padding:0;box-sizing:border-box}}
html,body{{width:1024px;height:500px;overflow:hidden}}
body{{font-family:'Changa',system-ui,sans-serif;position:relative;
     background:linear-gradient(118deg,#0a141d 0%,#10233a 46%,#0c2b26 100%)}}
.glow{{position:absolute;inset:0;
  background:radial-gradient(46% 90% at 12% 22%, rgba(47,163,122,.30) 0%, rgba(47,163,122,0) 70%),
             radial-gradient(40% 80% at 78% 96%, rgba(87,199,155,.20) 0%, rgba(87,199,155,0) 72%)}}
.grain{{position:absolute;inset:0;opacity:.5;
  background:repeating-linear-gradient(118deg, rgba(255,255,255,.015) 0 2px, rgba(0,0,0,0) 2px 5px)}}
.copy{{position:absolute;left:74px;top:0;height:100%;width:520px;
      display:flex;flex-direction:column;justify-content:center;z-index:5}}
.mark{{font-weight:700;font-size:82px;letter-spacing:1px;color:#57C79B;line-height:1}}
.tag{{margin-top:22px;font-weight:600;font-size:31px;line-height:1.24;color:#F1F7FA;max-width:430px}}
.note{{margin-top:18px;font-weight:400;font-size:21px;line-height:1.35;color:#8FB0C6;max-width:410px}}
.stage{{position:absolute;right:-10px;top:0;width:520px;height:100%}}
.paper{{position:absolute;left:6px;top:56px;width:250px;border-radius:10px;overflow:hidden;
       transform:rotate(-8deg);box-shadow:0 26px 50px rgba(0,0,0,.6)}}
.paper img{{display:block;width:100%}}
.arrow{{position:absolute;left:236px;top:236px;z-index:4}}
.phone{{position:absolute;left:286px;top:40px;width:216px;padding:6px;border-radius:26px;
       background:linear-gradient(158deg,#33495f,#16283a 60%,#243a4f);
       box-shadow:0 30px 60px rgba(0,0,0,.66), inset 0 1px 0 rgba(255,255,255,.10);z-index:3}}
.phone .screen{{border-radius:21px;overflow:hidden;background:#0F1D2B}}
.phone img{{display:block;width:100%}}
</style></head><body>
<div class="glow"></div><div class="grain"></div>
<div class="copy">
  <div class="mark">Scanote</div>
  <div class="tag">Photograph the page.<br>Keep the text.</div>
  <div class="note">Recognised on the phone, so the picture never leaves it.</div>
</div>
<div class="stage">
  <div class="paper"><img src="data:image/png;base64,{b64(f'{BUILD}/paper.png')}"></div>
  <svg class="arrow" width="70" height="34" viewBox="0 0 70 34" fill="none">
    <path d="M2 17h56" stroke="#2FA37A" stroke-width="5" stroke-linecap="round"/>
    <path d="M48 5l16 12-16 12" stroke="#2FA37A" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
  <div class="phone"><div class="screen">
    <img src="data:image/png;base64,{b64(f'{BUILD}/screen.png')}">
  </div></div>
</div>
</body></html>"""

open(f"{BUILD}/feature.html", "w").write(html)
subprocess.run([CHROME, "--headless", "--disable-gpu", "--hide-scrollbars",
                f"--screenshot={OUT}", "--window-size=1024,500",
                "--force-device-scale-factor=1", f"file://{BUILD}/feature.html"],
               capture_output=True)
print("->", os.path.relpath(OUT, S), Image.open(OUT).size)
