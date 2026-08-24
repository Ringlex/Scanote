"""Dopasowuje dostarczone grafiki do wymagan profilu dewelopera w Play.

    python3 fit_developer_art.py     # wymaga Google Chrome

Zrodla leza w supplied/. Play chce ikony 512x512 i naglowka **dokladnie**
4096x2304, oba ponizej 1 MB.

Ikona jest kwadratowa, wiec wystarczy ja przeskalowac. Naglowek ma proporcje
2.5:1 zamiast 16:9 — rozciagniecie go zdeformowaloby rysunek, a przyciecie
zabraloby jedna trzecia szerokosci razem z postacia albo z miastem. Zamiast
tego rysunek wchodzi na pelnej szerokosci, a pas nad nim i pod nim wypelnia
ten sam obraz, powiekszony i rozmyty. Krawedzie zgadzaja sie wtedy kolorem
i nie widac, gdzie konczy sie oryginal.
"""
import base64, os, subprocess

S = os.path.dirname(os.path.abspath(__file__))
SRC, BUILD, OUT = f"{S}/supplied", f"{S}/build", f"{S}/../developer"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
LIMIT = 900 * 1024        # Play tnie na 1 MB; zostawiamy zapas
os.makedirs(BUILD, exist_ok=True)
os.makedirs(OUT, exist_ok=True)

def under_limit(png, stem):
    """Zwraca PNG, jesli sie miesci; inaczej schodzi na JPEG."""
    if os.path.getsize(png) <= LIMIT:
        return png
    for quality in (86, 78, 70, 62, 54):
        jpg = f"{OUT}/{stem}.jpg"
        subprocess.run(["sips", "-s", "format", "jpeg", "-s", "formatOptions", str(quality),
                        png, "--out", jpg], capture_output=True)
        if os.path.getsize(jpg) <= LIMIT:
            os.remove(png)
            return jpg
    raise SystemExit(f"{stem}: nie zszedlem ponizej limitu nawet przy jakosci 54")

def report(path):
    size = subprocess.run(["sips", "-g", "pixelWidth", "-g", "pixelHeight", path],
                          capture_output=True, text=True).stdout
    dims = [line.split(":")[1].strip() for line in size.splitlines() if ":" in line
            and ("pixelWidth" in line or "pixelHeight" in line)]
    print(f"-> {os.path.relpath(path, S)}  {'x'.join(dims)}  {os.path.getsize(path)/1024:.0f} KB")

# --- ikona ------------------------------------------------------------------
# Zrodlo ma narysowany wlasny zaokraglony kwadrat na czarnym tle. Play naklada
# na ikone wlasna maske, wiec te marginesy zostalyby ciemna obwodka dookola.
# Przyblizamy kadr tak, zeby rysunek siegal krawedzi — reszte obetnie Play.
ZOOM = 1.30

icon_b64 = base64.b64encode(open(f"{SRC}/icon-source.png", "rb").read()).decode()
icon_html = f"""<!doctype html><html><head><meta charset="utf-8"><style>
*{{margin:0;padding:0}}
html,body{{width:512px;height:512px;overflow:hidden}}
.wrap{{width:512px;height:512px;overflow:hidden;position:relative}}
img{{position:absolute;left:50%;top:50%;width:512px;height:512px;
    transform:translate(-50%,-50%) scale({ZOOM})}}
</style></head><body><div class="wrap">
  <img src="data:image/png;base64,{icon_b64}">
</div></body></html>"""

path = f"{BUILD}/icon-art.html"
open(path, "w").write(icon_html)
icon = f"{OUT}/ringlex-icon-art-512.png"
subprocess.run([CHROME, "--headless", "--disable-gpu", "--hide-scrollbars",
                f"--screenshot={icon}", "--window-size=512,512",
                "--force-device-scale-factor=1", f"file://{path}"], capture_output=True)
report(under_limit(icon, "ringlex-icon-art-512"))

# --- naglowek ---------------------------------------------------------------
b64 = base64.b64encode(open(f"{SRC}/header-source.png", "rb").read()).decode()
html = f"""<!doctype html><html><head><meta charset="utf-8"><style>
*{{margin:0;padding:0}}
html,body{{width:2048px;height:1152px;overflow:hidden;background:#0b1c3f}}
.wrap{{position:relative;width:2048px;height:1152px;overflow:hidden}}
.fill{{position:absolute;inset:-80px;width:calc(100% + 160px);height:calc(100% + 160px);
      object-fit:cover;filter:blur(58px) saturate(1.05) brightness(.72)}}
.art{{position:absolute;left:0;top:50%;transform:translateY(-50%);width:2048px;display:block}}
</style></head><body><div class="wrap">
  <img class="fill" src="data:image/png;base64,{b64}">
  <img class="art"  src="data:image/png;base64,{b64}">
</div></body></html>"""

path = f"{BUILD}/header-art.html"
open(path, "w").write(html)
png = f"{OUT}/ringlex-header-art-4096.png"
subprocess.run([CHROME, "--headless", "--disable-gpu", "--hide-scrollbars",
                f"--screenshot={png}", "--window-size=2048,1152",
                "--force-device-scale-factor=2", f"file://{path}"], capture_output=True)
report(under_limit(png, "ringlex-header-art-4096"))
