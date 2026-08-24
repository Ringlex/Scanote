"""Measure the listing blocks against Play's field limits.

Each listing.md holds the app name, the short description and the full description as
fenced blocks, in that order. Play counts characters including spaces, so this counts
the same way and says which field is over.

    python3 source/check_listing.py
"""

import re
import sys
from pathlib import Path

FIELDS = (("app name", 30), ("short description", 80), ("full description", 4000))
FENCE = re.compile(r"^```\n(.*?)\n```$", re.S | re.M)

here = Path(__file__).resolve().parent.parent
over = False

for listing in sorted(here.glob("*/listing.md")):
    print(listing.relative_to(here.parent))
    blocks = FENCE.findall(listing.read_text())
    if len(blocks) < len(FIELDS):
        print(f"  only {len(blocks)} fenced blocks — expected {len(FIELDS)}")
        over = True
        continue
    for (name, limit), block in zip(FIELDS, blocks):
        count = len(block)
        mark = "over" if count > limit else "ok"
        if count > limit:
            over = True
        print(f"  {name:<18} {count:>5} / {limit:<5} {mark}")

sys.exit(1 if over else 0)
