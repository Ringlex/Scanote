"""Oprawia surowe zrzuty (raw/) w ramkę telefonu z hasłem i zapisuje do ../en-US/phone.

    python3 compose.py          # wymaga Pillow i Google Chrome

Surowe zrzuty biorą się z:
    adb exec-out screencap -p > raw/<nazwa>.png
na telefonie 1080x2400; TOP/BOTTOM przycinają pasek stanu i pasek nawigacji.
"""
import base64, os, subprocess
from PIL import Image

S = os.path.dirname(os.path.abspath(__file__))
RAW, OUT, BUILD, FONTS = f"{S}/raw", f"{S}/../en-US/phone", f"{S}/build", f"{S}/fonts"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
os.makedirs(OUT, exist_ok=True)
os.makedirs(BUILD, exist_ok=True)

TOP, BOTTOM = 115, 2268        # pasek stanu / pasek nawigacji urządzenia
FRAME_W, STATUS_H, PHONE_TOP = 690, 52, 452

def b64(path):
    with open(path, "rb") as f:
        return base64.b64encode(f.read()).decode()

FONT_FACES = "".join(
    f"@font-face{{font-family:'Changa';font-weight:{w};font-style:normal;"
    f"src:url(data:font/ttf;base64,{b64(f'{FONTS}/changa-{i}.ttf')}) format('truetype');}}"
    for i, w in ((1, 400), (2, 600), (3, 700))
)

# (plik wyjściowy, zrzut w raw/, nagłówek, podpis)
SHOTS = [
    ("01-photo-becomes-a-note",             "02-scan-note.png",  "A photo of the page<br>becomes a note",
     "Text recognition runs on the phone. The picture never leaves it."),
    ("02-scanned-list-becomes-a-checklist", "03-checklist.png",  "A scanned list arrives<br>as a checklist",
     "Tick it off in the shop. The photo stays with the note."),
    ("03-everything-in-one-place",          "01-home.png",       "Everything you scanned,<br>in one place",
     "Categories, favourites, and a bin that waits thirty days."),
    ("04-search-inside-photographs",        "06-search.png",     "Search reaches inside<br>your photographs",
     "Words you never typed are still words you can find."),
    ("05-fingerprint-protected-notes",      "05-protection.png", "Notes only your<br>fingerprint opens",
     "AES-256-GCM, with the key held in the Android Keystore."),
    ("06-formatting-that-renders",          "04-formatting.png", "Headings and lists<br>that render",
     "Write it with the toolbar, read it back properly."),
    ("07-calendar-and-reminders",           "07-calendar.png",   "Dates and reminders<br>in the same app",
     "The note and the day it belongs to, side by side."),
    ("08-sync-and-backup",                  "08-sync.png",       "Your notes on<br>every phone",
     "Backup to your own Drive. Scans and protected notes stay put."),
]

TEMPLATE = """<!doctype html><html><head><meta charset="utf-8"><style>
%(fonts)s
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:1080px;height:1920px;overflow:hidden}
body{font-family:'Changa',system-ui,sans-serif;position:relative;
     background:linear-gradient(163deg,#0a141d 0%%,#122539 52%%,#0c2a26 100%%);}
.glow{position:absolute;inset:0;
      background:radial-gradient(58%% 34%% at 18%% 6%%, rgba(47,163,122,.30) 0%%, rgba(47,163,122,0) 70%%),
                 radial-gradient(50%% 30%% at 92%% 84%%, rgba(87,199,155,.16) 0%%, rgba(87,199,155,0) 72%%);}
.grain{position:absolute;inset:0;opacity:.5;
       background:repeating-linear-gradient(115deg, rgba(255,255,255,.014) 0 2px, rgba(0,0,0,0) 2px 5px);}
.wrap{position:relative;height:100%%;display:flex;flex-direction:column;align-items:center;
      padding:80px 78px 0;}
.rule{width:74px;height:7px;border-radius:4px;background:#2FA37A;margin-bottom:34px}
h1{font-weight:700;font-size:66px;line-height:1.1;color:#F3F8FB;text-align:center;letter-spacing:.4px}
p.sub{margin-top:22px;font-weight:400;font-size:31px;line-height:1.34;color:#8FB0C6;
      text-align:center;max-width:790px}
.phone{position:absolute;left:50%%;transform:translateX(-50%%);top:%(top)spx;
       width:%(fw)spx;padding:12px;border-radius:56px;
       background:linear-gradient(158deg,#33495f,#16283a 60%%,#243a4f);
       box-shadow:0 46px 90px rgba(0,0,0,.62), 0 12px 26px rgba(0,0,0,.5),
                  inset 0 1px 0 rgba(255,255,255,.10);}
.screen{border-radius:45px;overflow:hidden;background:#0F1D2B;position:relative}
.status{height:%(sh)spx;display:flex;align-items:center;justify-content:space-between;
        padding:0 34px;background:#0F1D2B;color:#A7C0D3;font-size:25px;font-weight:600;letter-spacing:.6px}
.status .icons{display:flex;align-items:center;gap:12px}
.shot{display:block;width:100%%}
.gloss{position:absolute;inset:0;border-radius:45px;pointer-events:none;
       background:linear-gradient(118deg, rgba(255,255,255,.055) 0%%, rgba(255,255,255,0) 26%%,
                  rgba(255,255,255,0) 74%%, rgba(255,255,255,.028) 100%%)}
</style></head><body>
<div class="glow"></div><div class="grain"></div>
<div class="wrap"><div class="rule"></div><h1>%(head)s</h1><p class="sub">%(sub)s</p></div>
<div class="phone"><div class="screen">
  <div class="status"><span>9:41</span><span class="icons">
    <svg width="30" height="22" viewBox="0 0 24 18" fill="none"><path d="M12 15.4l2.6-2.9a3.6 3.6 0 00-5.2 0L12 15.4z" fill="#A7C0D3"/><path d="M6.4 9.3a8.4 8.4 0 0111.2 0" stroke="#A7C0D3" stroke-width="1.9" stroke-linecap="round"/><path d="M2.6 5.4a13.8 13.8 0 0118.8 0" stroke="#A7C0D3" stroke-width="1.9" stroke-linecap="round"/></svg>
    <svg width="42" height="22" viewBox="0 0 34 18" fill="none"><rect x="1" y="2.6" width="27" height="12.8" rx="4" stroke="#A7C0D3" stroke-width="1.8"/><rect x="3.6" y="5.2" width="21.8" height="7.6" rx="2.2" fill="#A7C0D3"/><path d="M30.4 7v4" stroke="#A7C0D3" stroke-width="2.6" stroke-linecap="round"/></svg>
  </span></div>
  <img class="shot" src="data:image/png;base64,%(img)s">
  <div class="gloss"></div>
</div></div>
</body></html>"""

for name, src, head, sub in SHOTS:
    im = Image.open(f"{RAW}/{src}").convert("RGB").crop((0, TOP, 1080, BOTTOM))
    crop = f"{BUILD}/crop-{name}.png"
    im.save(crop)
    html = TEMPLATE % dict(fonts=FONT_FACES, img=b64(crop), head=head, sub=sub,
                           top=PHONE_TOP, fw=FRAME_W, sh=STATUS_H)
    page = f"{BUILD}/{name}.html"
    open(page, "w").write(html)
    subprocess.run([CHROME, "--headless", "--disable-gpu", "--hide-scrollbars",
                    f"--screenshot={OUT}/{name}.png", "--window-size=1080,1920",
                    "--force-device-scale-factor=1", f"file://{page}"], capture_output=True)
    print(f"{src} -> en-US/phone/{name}.png")
