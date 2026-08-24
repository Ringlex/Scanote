"""Sklada grafiki profilu dewelopera Ringlex do ../developer.

    python3 brand.py            # wymaga Google Chrome, nie wymaga Pillow

Dwa pliki, oba w wymiarach, ktorych zada Play Console:

    ringlex-icon-512.png       512x512    ikona dewelopera
    ringlex-header-4096.png    4096x2304  obraz naglowka

Paleta jest ta sama co w aplikacji (lib/core/theme/theme.dart), zeby profil
i ikona Scanote wygladaly na rodzenstwo, a nie na dwie przypadkowe rzeczy.
"""
import base64, os, subprocess

S = os.path.dirname(os.path.abspath(__file__))
FONTS, BUILD, OUT = f"{S}/fonts", f"{S}/build", f"{S}/../developer"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
os.makedirs(BUILD, exist_ok=True)
os.makedirs(OUT, exist_ok=True)

INK, GREEN, GREEN_LIT, PAPER = "#10202F", "#2FA37A", "#57C79B", "#F5F8FB"

FONT_FACES = "".join(
    f"@font-face{{font-family:'Changa';font-weight:{w};font-style:normal;"
    f"src:url(data:font/ttf;base64,"
    f"{base64.b64encode(open(f'{FONTS}/changa-{i}.ttf','rb').read()).decode()}) format('truetype');}}"
    for i, w in ((1, 400), (2, 600), (3, 700))
)

LIMIT = 900 * 1024       # Play odrzuca powyzej 1 MB; trzymamy zapas

def shoot(html, name, w, h, scale):
    path = f"{BUILD}/{name}.html"
    open(path, "w").write(html)
    dest = f"{OUT}/{name}.png"
    subprocess.run([CHROME, "--headless", "--disable-gpu", "--hide-scrollbars",
                    f"--screenshot={dest}", f"--window-size={w},{h}",
                    f"--force-device-scale-factor={scale}", f"file://{path}"],
                   capture_output=True)

    # Gradient przez 4096 pikseli to dla PNG najgorszy mozliwy material — kazdy
    # pas to inny kolor, wiec kompresja bezstratna nie ma czego skracac i plik
    # wychodzi grubo ponad limit. JPEG radzi sobie z tym samym obrazem
    # kilkunastokrotnie lepiej i Play przyjmuje oba formaty.
    if os.path.getsize(dest) <= LIMIT:
        return dest

    for quality in (80, 72, 64, 56):
        jpg = f"{OUT}/{name}.jpg"
        subprocess.run(["sips", "-s", "format", "jpeg",
                        "-s", "formatOptions", str(quality), dest, "--out", jpg],
                       capture_output=True)
        if os.path.getsize(jpg) <= LIMIT:
            os.remove(dest)
            return jpg
    raise SystemExit(f"{name}: nie zszedlem ponizej 1 MB nawet przy jakosci 60")

# --- ikona ------------------------------------------------------------------
# Monogram na wzor litery S w ikonie Scanote: ta sama czcionka, ten sam granat,
# ta sama zielen. Pierscien zostaje na naglowek — w 48 pikselach zlalby sie
# z litera i zrobil plame.
icon = f"""<!doctype html><html><head><meta charset="utf-8"><style>
{FONT_FACES}
*{{margin:0;padding:0;box-sizing:border-box}}
html,body{{width:512px;height:512px;overflow:hidden;background:{INK}}}
body{{font-family:'Changa',system-ui,sans-serif;display:flex;
     align-items:center;justify-content:center}}
.mark{{font-weight:700;font-size:392px;line-height:1;letter-spacing:-.02em;
      background:linear-gradient(155deg,{GREEN_LIT} 0%,{GREEN} 62%,#268B67 100%);
      -webkit-background-clip:text;-webkit-text-fill-color:transparent;
      transform:translateY(-8px)}}
</style></head><body><div class="mark">R</div></body></html>"""

# --- naglowek ---------------------------------------------------------------
# Play przycina naglowek roznie na roznych ekranach, wiec wszystko, co ma byc
# widoczne, siedzi w srodkowej trzeciej czesci. Pierscienie sa dekoracja i moga
# zostac obciete bez straty.
header = f"""<!doctype html><html><head><meta charset="utf-8"><style>
{FONT_FACES}
*{{margin:0;padding:0;box-sizing:border-box}}
html,body{{width:2048px;height:1152px;overflow:hidden}}
body{{font-family:'Changa',system-ui,sans-serif;position:relative;
     background:linear-gradient(118deg,#0a141d 0%,#10233a 46%,#0c2b26 100%)}}
.glow{{position:absolute;inset:0;
  background:radial-gradient(44% 86% at 16% 20%, rgba(47,163,122,.26) 0%, rgba(47,163,122,0) 70%),
             radial-gradient(40% 80% at 84% 92%, rgba(87,199,155,.18) 0%, rgba(87,199,155,0) 72%)}}
.rings{{position:absolute;inset:0;display:flex;align-items:center;justify-content:center}}
.rings div{{position:absolute;border-radius:50%;border:2px solid rgba(87,199,155,.16)}}
.r1{{width:760px;height:760px}}
.r2{{width:1120px;height:1120px;border-color:rgba(87,199,155,.10)}}
.r3{{width:1520px;height:1520px;border-color:rgba(87,199,155,.06)}}
.grain{{position:absolute;inset:0;opacity:.5;
  background:repeating-linear-gradient(118deg, rgba(255,255,255,.015) 0 2px, rgba(0,0,0,0) 2px 5px)}}
.copy{{position:absolute;inset:0;display:flex;flex-direction:column;
      align-items:center;justify-content:center;z-index:5}}
.word{{font-weight:700;font-size:200px;line-height:1;letter-spacing:.06em;
      color:{PAPER}}}
.word span{{color:{GREEN_LIT}}}
.rule{{width:220px;height:5px;border-radius:3px;background:{GREEN};margin:44px 0 34px}}
.tag{{font-weight:600;font-size:44px;letter-spacing:.26em;color:#8FA6BC;
     text-transform:uppercase}}
</style></head><body>
<div class="glow"></div>
<div class="rings"><div class="r1"></div><div class="r2"></div><div class="r3"></div></div>
<div class="grain"></div>
<div class="copy">
  <div class="word"><span>R</span>INGLEX</div>
  <div class="rule"></div>
  <div class="tag">Apps that keep your data yours</div>
</div>
</body></html>"""

for html, name, w, h, scale in ((icon, "ringlex-icon-512", 512, 512, 1),
                                (header, "ringlex-header-4096", 2048, 1152, 2)):
    dest = shoot(html, name, w, h, scale)
    size = os.path.getsize(dest)
    print(f"-> {os.path.relpath(dest, S)}  {size/1024:.0f} KB")
