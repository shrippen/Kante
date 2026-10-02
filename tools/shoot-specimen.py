#!/usr/bin/env python3
"""Renders tools/specimen.html in all four variants at two widths, one image per section.

A new web element is done only when it looks right in every variant:
  dark (default), Leinen (data-theme="light"), Kante Light (data-kante="light"), Kante Gold (data-kante="gold").
Writes dist/specimen/<variant>-<width>-<section>.png. Needs Python with Playwright (Chromium);
build.sh runs it when $KANTE_PY (default: the demo tools venv in shrippen.github.io) has it.
Usage: python3 tools/shoot-specimen.py
"""
from pathlib import Path

from playwright.sync_api import sync_playwright

KANTE = Path(__file__).resolve().parent.parent
PAGE = (KANTE / "tools/specimen.html").as_uri()
OUT = KANTE / "dist/specimen"
WIDTHS = (1200, 390)
FONT_WAIT_MS = 400

# Root attributes per variant: (data-theme, data-kante)
VARIANTS = {
    "dark": (None, None),
    "leinen": ("light", None),
    "kante-light": (None, "light"),
    "gold": ("dark", "gold"),
}


def shoot(browser, name, attrs, width):
    """One page per variant and width; every <section id> becomes one image."""
    page = browser.new_page(viewport={"width": width, "height": 900})
    page.goto(PAGE)
    theme, kante = attrs
    page.evaluate("([t, k]) => { const r = document.documentElement;"
                  " if (t) r.dataset.theme = t; if (k) r.dataset.kante = k; }", [theme, kante])
    page.wait_for_timeout(FONT_WAIT_MS)

    count = 0
    for section in page.query_selector_all("section[id]"):
        section.screenshot(path=OUT / f"{name}-{width}-{section.get_attribute('id')}.png")
        count += 1
    page.close()
    return count


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    with sync_playwright() as p:
        browser = p.chromium.launch()
        total = sum(shoot(browser, n, a, w) for n, a in VARIANTS.items() for w in WIDTHS)
        browser.close()
    print(f"specimen: {total} images in {OUT.relative_to(KANTE)}")


if __name__ == "__main__":
    main()
