# Store assets

What goes into the Play Console listing, and how it was made. **en-US** is complete —
text, screenshots, feature graphic and icon. **pl-PL** has its text written; its
screenshots still have to be captured with the app set to Polish.

```
store/
├── en-US/
│   ├── listing.md the name, short and full description, ready to paste
│   ├── phone/     8 × 1080×1920 — the phone screenshots, in listing order
│   └── graphics/  the 1024×500 feature graphic and the 512×512 store icon
├── pl-PL/
│   └── listing.md the Polish text; its screenshots are not taken yet
└── source/
    ├── raw/       untouched 1080×2400 device captures
    ├── fonts/     Changa, the app's own typeface, for the headlines
    ├── compose.py builds phone/ from raw/
    ├── feature.py builds graphics/ from raw/ and paper-list.png
    └── check_listing.py measures listing.md against Play's field limits
```

## The eight screenshots

Order matters — Play shows them in this sequence, and most people never scroll past
the third.

| # | Screen | Headline |
|---|---|---|
| 1 | a scanned lecture page | A photo of the page becomes a note |
| 2 | a scanned list, as a checklist | A scanned list arrives as a checklist |
| 3 | the note grid | Everything you scanned, in one place |
| 4 | search | Search reaches inside your photographs |
| 5 | the editor's protection row | Notes only your fingerprint opens |
| 6 | a note with formatting | Headings and lists that render |
| 7 | the calendar | Dates and reminders in the same app |
| 8 | settings, sync and backup | Your notes on every phone |

Every claim in the headlines is one the app actually keeps: recognition is on-device,
the encryption is AES-256-GCM under a Keystore key, the bin holds for thirty days, and
sync leaves scans and protected notes on the phone.

## The demo content is demo content

The notes in the screenshots are made up — a seeded database, not anyone's real notes.
Two of them are not: **the lecture page and the shopping list went through the app's own
scanner and ML Kit**, so the recognised text in screenshots 1 and 2 is genuinely what the
app produced. The photographed pages themselves (`source/paper-*.png`) are rendered,
not photographs of real paper.

Nothing personal appears anywhere — settings is scrolled so that the account section
stays below the fold.

## Regenerating

Needs Python with Pillow, and Google Chrome at the usual macOS path.

```bash
cd store/source
python3 compose.py     # → ../en-US/phone
python3 feature.py     # → ../en-US/graphics
```

Both read from `source/raw/`, so re-running them only re-frames what is already there.

## Taking new raw captures

The captures are 1080×2400 from a phone at that resolution. `compose.py` crops
`TOP=115` and `BOTTOM=2268` to drop the device's status and navigation bars and draws
its own clean status bar in the frame — so the real clock, battery and notification
icons never reach the listing. **Change the phone and those two numbers change.**

```bash
adb exec-out screencap -p > store/source/raw/01-home.png
```

The system fingerprint dialog cannot be captured — it is a secure window and
`screencap` returns an empty file. That is why screenshot 5 shows the editor's
protection row instead of the prompt.

## The written listing

`en-US/listing.md` and `pl-PL/listing.md` hold the app name, the short description and
the full description, each in a fenced block sized to Play's limit — 30, 80 and 4000
characters. Play counts spaces too, so re-check the lengths after any edit:

```bash
cd store/source
python3 check_listing.py
```

Both texts describe only what the app does today — recognition on the device, the
Keystore-backed encryption, the thirty-day bin, and sync that leaves scans and protected
notes behind. Keep it that way when the wording changes.

## The store icon

`en-US/graphics/icon-512x512.png` is `assets/icon/app_icon.png` scaled down. Play wants a
512×512 32-bit PNG **without** transparency; the source has no alpha channel, so the
scale is the whole job:

```bash
sips -Z 512 assets/icon/app_icon.png --out store/en-US/graphics/icon-512x512.png
```

## The developer profile

`developer/` holds the two images for the **Ringlex** developer page, which is a separate
listing from Scanote's own:

| File | Size | Field |
|---|---|---|
| `ringlex-icon-512.png` | 512×512 | developer icon — plain monogram |
| `ringlex-header-4096.jpg` | 4096×2304 | header image — plain monogram |
| `ringlex-icon-comic-512.png` | 512×512 | developer icon — comic book |
| `ringlex-header-comic-4096.png` | 4096×2304 | header image — comic book |

**Two complete sets, one pair of fields.** Upload either the two plain files or the two
comic ones — mixing them looks like an accident. `brand.py` builds the plain set,
`brand_comic.py` the comic one.

The plain set follows Scanote's own icon: same Changa, same ink, same green, so the app
and its publisher read as related. The comic set drops that for black ink lines of
varying weight, rays out of the centre, halftone dots instead of shading and flat colour;
the only thing tying it back to the app is the green in the emblem.

Both scripts cap the output at 900 KB, under Play's 1 MB limit, and fall back to JPEG when
PNG will not fit. The plain header needs that fallback — a gradient across 4096 pixels
compressed losslessly comes to 7 MB. The comic header does not: flat colour stays a 267 KB
PNG.

Play crops the header differently on different screens, so everything that must stay
readable sits in the middle third. The rings are decoration and can be cut without loss.

```bash
cd store/source
python3 brand.py       # needs Chrome; no Pillow required
```

## Data safety and content rating

`data-safety.md` holds the answers to the Data safety form, each traced back to the code
it follows from. The content rating questionnaire is every answer "No" under the
"all other app types" category — no ads, no purchases, no user-to-user features.

## Still missing before submission

- [ ] 7" and 10" tablet screenshots, or Play flags the app as not tablet-optimised
- [ ] `pl-PL/phone/` — the Polish screenshots, captured with the app set to Polish
- [ ] The privacy policy and terms published at public URLs, with their `[UZUPEŁNIĆ …]`
      fields filled in — the listing cannot go in for review without them
