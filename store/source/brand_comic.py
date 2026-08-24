"""Ikona i naglowek dewelopera w stylistyce komiksu.

    python3 brand_comic.py      # wymaga Google Chrome

Chwyty wziete wprost z okladek: czarny kontur o zmiennej grubosci, promienie
bijace z centrum, rastr kropkowy zamiast cieniowania i plaskie, mocne kolory.
Zielen emblematu zostaje ta sama co w aplikacji — to jedyne, co laczy ikone
dewelopera z ikona Scanote.
"""
import base64, math, os, subprocess

S = os.path.dirname(os.path.abspath(__file__))
BUILD, OUT, FONTS = f"{S}/build", f"{S}/../developer", f"{S}/fonts"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
os.makedirs(BUILD, exist_ok=True)
os.makedirs(OUT, exist_ok=True)

LINE   = "#141A22"   # kontur — w komiksie zawsze czarny
GOLD   = "#F5C542"
GOLD_D = "#E2A92E"
RED    = "#E03B2F"
BLUE   = "#2C6CB0"
BLUE_D = "#1E4E85"
SKIN   = "#F3C9A2"
SKIN_D = "#DCA87C"
HAIR   = "#2A2118"
GREEN  = "#2FA37A"
WHITE  = "#FFF8EC"

# Promienie z centrum — co drugi ciemniejszy, jak na okladce.
def rays(cx, cy, reach, step=15):
    out = []
    for i in range(360 // step):
        if i % 2:
            continue
        a1, a2 = math.radians(i * step), math.radians(i * step + step)
        out.append(
            f'<path d="M{cx} {cy} '
            f'L{cx + reach * math.cos(a1):.0f} {cy + reach * math.sin(a1):.0f} '
            f'L{cx + reach * math.cos(a2):.0f} {cy + reach * math.sin(a2):.0f} Z" '
            f'fill="{GOLD_D}"/>')
    return "".join(out)

RAYS = rays(256, 256, 900)

FONT_FACES = "".join(
    f"@font-face{{font-family:'Changa';font-weight:{w};font-style:normal;"
    f"src:url(data:font/ttf;base64,"
    f"{base64.b64encode(open(f'{FONTS}/changa-{i}.ttf','rb').read()).decode()}) format('truetype');}}"
    for i, w in ((1, 400), (2, 600), (3, 700)))

SVG = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <defs>
    <pattern id="dots" width="16" height="16" patternUnits="userSpaceOnUse">
      <circle cx="4" cy="4" r="3.4" fill="{RED}" opacity=".55"/>
    </pattern>
    <clipPath id="frame"><rect width="512" height="512"/></clipPath>
  </defs>

  <g clip-path="url(#frame)">
    <rect width="512" height="512" fill="{GOLD}"/>
    {RAYS}
    <path d="M0 300 L150 512 L0 512 Z" fill="url(#dots)"/>
    <path d="M512 300 L362 512 L512 512 Z" fill="url(#dots)"/>

    <g stroke="{LINE}" stroke-linejoin="round" stroke-linecap="round" fill="none">

      <!-- barki i tors w kostiumie -->
      <path d="M84 512 C84 396 158 330 256 330 C354 330 428 396 428 512 Z"
            fill="{BLUE}" stroke-width="13"/>
      <path d="M256 330 C210 330 176 350 152 380 L152 512 L96 512
               C96 402 166 344 256 344 Z" fill="{BLUE_D}" stroke-width="9"/>

      <!-- emblemat na piersi -->
      <circle cx="256" cy="438" r="54" fill="{WHITE}" stroke-width="12"/>
      <text x="256" y="456" font-family="Menlo,monospace" font-size="44" font-weight="700"
            fill="{GREEN}" stroke="none" text-anchor="middle">&lt;/&gt;</text>

      <!-- szyja -->
      <path d="M222 292 L222 340 L290 340 L290 292 Z" fill="{SKIN_D}" stroke-width="11"/>

      <!-- glowa -->
      <path d="M176 190 C176 122 210 88 256 88 C302 88 336 122 336 190
               C336 250 302 292 256 292 C210 292 176 250 176 190 Z"
            fill="{SKIN}" stroke-width="13"/>
      <!-- cien komiksowy po prawej stronie twarzy -->
      <path d="M310 126 C328 144 336 164 336 190 C336 236 315 271 285 285
               C306 260 318 228 318 190 C318 164 316 142 310 126 Z"
            fill="{SKIN_D}" stroke-width="0"/>

      <!-- maska -->
      <path d="M170 168 C200 148 312 148 342 168 L336 210
               C320 226 296 232 256 232 C216 232 192 226 176 210 Z"
            fill="{RED}" stroke-width="13"/>
      <path d="M198 186 C206 170 232 168 244 182 C232 200 206 200 198 186 Z" fill="{WHITE}" stroke-width="9"/>
      <path d="M314 186 C306 170 280 168 268 182 C280 200 306 200 314 186 Z" fill="{WHITE}" stroke-width="9"/>

      <!-- wlosy -->
      <path d="M172 176 C160 106 204 66 256 66 C308 66 352 106 340 176
               L326 150 C310 118 288 104 256 104 C224 104 202 118 186 150 Z"
            fill="{HAIR}" stroke-width="13"/>

      <!-- szczeka i usta -->
      <path d="M232 258 C244 266 268 266 280 258" stroke-width="11"/>
    </g>
  </g>
</svg>"""

html = f"""<!doctype html><html><head><meta charset="utf-8"><style>
*{{margin:0;padding:0}} html,body{{width:512px;height:512px;overflow:hidden}}
</style></head><body>{SVG}</body></html>"""

path = f"{BUILD}/icon-comic.html"
open(path, "w").write(html)
dest = f"{OUT}/ringlex-icon-comic-512.png"
subprocess.run([CHROME, "--headless", "--disable-gpu", "--hide-scrollbars",
                f"--screenshot={dest}", "--window-size=512,512",
                "--force-device-scale-factor=1", f"file://{path}"], capture_output=True)
print(f"-> {os.path.relpath(dest, S)}  {os.path.getsize(dest)/1024:.0f} KB")

# --- naglowek 4096x2304 -----------------------------------------------------
# Play przycina naglowek roznie na kazdym ekranie, wiec napis i wstega siedza
# w srodkowej trzeciej czesci. Promienie i rastr moga zostac obciete.
HEADER = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 2048 1152" width="2048" height="1152">
  <defs>
    <pattern id="hdots" width="34" height="34" patternUnits="userSpaceOnUse">
      <circle cx="9" cy="9" r="7" fill="{RED}" opacity=".5"/>
    </pattern>
  </defs>
  <rect width="2048" height="1152" fill="{GOLD}"/>
  {rays(1024, 576, 2600)}
  <path d="M0 660 L360 1152 L0 1152 Z" fill="url(#hdots)"/>
  <path d="M2048 660 L1688 1152 L2048 1152 Z" fill="url(#hdots)"/>

  <g font-family="Changa" font-weight="700" text-anchor="middle">
    <text x="1024" y="562" font-size="270" letter-spacing="10"
          fill="{LINE}" opacity=".35" transform="translate(16 18)">RINGLEX</text>
    <text x="1024" y="562" font-size="270" letter-spacing="10"
          fill="{RED}" stroke="{LINE}" stroke-width="26" paint-order="stroke"
          stroke-linejoin="round">RINGLEX</text>
  </g>

  <g stroke="{LINE}" stroke-width="14" stroke-linejoin="round">
    <path d="M470 656 L1578 642 L1578 790 L470 804 Z" fill="{BLUE}"/>
  </g>
  <text x="1024" y="742" font-family="Changa" font-weight="600" font-size="58"
        letter-spacing="12" fill="{WHITE}" text-anchor="middle"
        transform="rotate(-0.72 1024 730)">YOUR DATA STAYS YOURS</text>
</svg>"""

html = f"""<!doctype html><html><head><meta charset="utf-8"><style>
{FONT_FACES}
*{{margin:0;padding:0}} html,body{{width:2048px;height:1152px;overflow:hidden}}
</style></head><body>{HEADER}</body></html>"""

path = f"{BUILD}/header-comic.html"
open(path, "w").write(html)
png = f"{OUT}/ringlex-header-comic-4096.png"
subprocess.run([CHROME, "--headless", "--disable-gpu", "--hide-scrollbars",
                f"--screenshot={png}", "--window-size=2048,1152",
                "--force-device-scale-factor=2", f"file://{path}"], capture_output=True)

# Rastr i promienie to dla PNG material rownie zly jak gradient — schodzimy na
# JPEG, bo Play tnie oba pliki na 1 MB.
LIMIT = 900 * 1024
dest = png
if os.path.getsize(png) > LIMIT:
    for quality in (82, 74, 66, 58):
        jpg = f"{OUT}/ringlex-header-comic-4096.jpg"
        subprocess.run(["sips", "-s", "format", "jpeg", "-s", "formatOptions", str(quality),
                        png, "--out", jpg], capture_output=True)
        if os.path.getsize(jpg) <= LIMIT:
            os.remove(png)
            dest = jpg
            break
print(f"-> {os.path.relpath(dest, S)}  {os.path.getsize(dest)/1024:.0f} KB")
