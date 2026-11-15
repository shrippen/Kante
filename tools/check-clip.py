#!/usr/bin/env python3
"""Checks the cut corner: the computed clip-path of every element of tools/clip-fixture.html
(and its ::before and ::after) against tools/clip-expected.json.

The fixture holds one instance of every surface with the cut corner, the two-cut surfaces and
the cases that give the cut up. It is read in four variants (dark, Leinen, Kante Light, Gold)
at 1200 and 390 px with every <details> open, and without transitions and animations.

Usage: python3 tools/check-clip.py [--css path/to/shrippen.css] [--update]
  --css     the stylesheet to test (default docs/v1/shrippen.css)
  --update  write the expectation from the stylesheet instead of comparing
Needs Python with Playwright (Chromium); build.sh runs it when $KANTE_PY has it. Exit 1 on a difference.
"""
import argparse
import json
import sys
from pathlib import Path

from playwright.sync_api import sync_playwright

KANTE = Path(__file__).resolve().parent.parent
FIXTURE = KANTE / "tools/clip-fixture.html"
EXPECTED = KANTE / "tools/clip-expected.json"
DEFAULT_CSS = "docs/v1/shrippen.css"
WIDTHS = (1200, 390)
SETTLE_MS = 300

# Root attributes per variant: (data-theme, data-kante)
VARIANTS = {"dark": (None, None), "leinen": ("light", None), "kante-light": (None, "light"), "gold": ("dark", "gold")}

STILL = "*,*::before,*::after{transition:none!important;animation:none!important}"
SET_VARIANT = """([t, k]) => { const r = document.documentElement;
  if (t) r.dataset.theme = t; if (k) r.dataset.kante = k;
  document.querySelectorAll('details').forEach(d => d.open = true); }"""
READ = """() => [...document.querySelectorAll('body *')].map((el, i) => [
  i + ' ' + el.tagName.toLowerCase() + '.' + (el.getAttribute('class') || '') + '|' + (el.dataset.fx || ''),
  ...[null, '::before', '::after'].map(p => getComputedStyle(el, p).clipPath)])"""


def read_all(css):
    """{"<variant>-<width>": [[label, clip, before, after], ...]} for the stylesheet."""
    html = FIXTURE.read_text().replace("../docs/v1/shrippen.css", Path(css).resolve().as_uri())
    page_file = FIXTURE.with_name(".clip-fixture-run.html")
    page_file.write_text(html)
    result = {}
    try:
        with sync_playwright() as p:
            browser = p.chromium.launch()
            for name, attrs in VARIANTS.items():
                for width in WIDTHS:
                    page = browser.new_page(viewport={"width": width, "height": 900})
                    page.goto(page_file.as_uri())
                    page.add_style_tag(content=STILL)
                    page.evaluate(SET_VARIANT, list(attrs))
                    page.wait_for_timeout(SETTLE_MS)
                    result[f"{name}-{width}"] = page.evaluate(READ)
                    page.close()
            browser.close()
    finally:
        page_file.unlink()
    return result


def differences(expected, actual):
    for key, rows in expected.items():
        got = actual.get(key, [])
        if len(got) != len(rows):
            yield f"{key}: {len(got)} elements, expected {len(rows)}"
            continue
        for want, have in zip(rows, got):
            if want != have:
                yield f"{key}: {want[0]}\n    expected {want[1:]}\n    got      {have[1:]}"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--css", default=str(KANTE / DEFAULT_CSS))
    parser.add_argument("--update", action="store_true")
    args = parser.parse_args()

    actual = read_all(args.css)
    if args.update:
        EXPECTED.write_text(json.dumps(actual, indent=0) + "\n")
        print(f"check-clip: {EXPECTED.relative_to(KANTE)} written")
        return 0

    problems = list(differences(json.loads(EXPECTED.read_text()), actual))
    print("\n".join(problems) or f"check-clip ok ({sum(len(r) for r in actual.values())} rows)")
    return 1 if problems else 0


sys.exit(main())
