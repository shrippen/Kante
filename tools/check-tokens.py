#!/usr/bin/env python3
"""Checks that the design system's sources use tokens instead of raw values.

  - No raw hex colours outside tokens/variables.css. The only exception is a custom
    property that re-sets a token locally (e.g. `.stage{--bg1:#3c3836}`), and its value
    must be one of the hex values defined in tokens/variables.css.
  - font-family always comes from a token: var(--font-heading|--font-sans|--font-mono|--font-control) or inherit.
  - A fill that marks "active / chosen / working" uses --primary, never --yellow: in Leinen and
    Kante Light --yellow is a text colour (ochre, orange). Only the brand marks in YELLOW_FILL_OK
    may fill with --yellow.
  - Web and apps share one palette: every colour in tokens/palette.json (dark and the
    light theme "Leinen" and Kante Gold) has the same value as its custom property in tokens/variables.css.

Scans css/*.css, templates/*.html, the landing pages in docs/ and any HTML file given as argument (in HTML only <style>, style="…"
and fill/stroke/color attributes). Exits 1 on any finding.
Usage: python3 tools/check-tokens.py [page.html ...]   (build.sh runs it; shrippen.github.io passes its overview)
"""
import re
import sys
from pathlib import Path

KANTE = Path(__file__).resolve().parent.parent
REPO = KANTE
HEX = re.compile(r"#(?:[0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{3,4})\b")
TOKEN_HEX = {h.lower() for h in HEX.findall((KANTE / "tokens/variables.css").read_text())}
FONT = re.compile(r"font-family\s*:\s*([^;}\"]+)", re.I)
FONT_OK = re.compile(r"^(var\(--font-(heading|sans|mono|control)\)|inherit)$")
CUSTOM_PROP = re.compile(r"\s*--[\w-]+\s*:")
YELLOW_FILL = re.compile(r"background(?:-color)?\s*:\s*var\(--yellow\)")
# Brand marks on the landing page, the "today" mark (a data colour, as its yellow text), the crop
# handles on the always-dark image stage, and Kante Gold
YELLOW_FILL_OK = re.compile(r'\.nav-brand|\.foot-meta|\.install-card|\.showcase|\.today|\.handle|\.seam|data-kante="gold"')


def blank(m):
    """Replaces a match with spaces but keeps newlines, so line numbers stay right."""
    return re.sub(r"[^\n]", " ", m.group(0))


def css_regions(path, text):
    """Returns the text with comments and everything that is not CSS blanked out."""
    text = re.sub(r"/\*.*?\*/", blank, text, flags=re.S)
    if path.suffix == ".css":
        return text
    text = re.sub(r"<!--.*?-->", blank, text, flags=re.S)
    keep = [m.span(1) for m in re.finditer(r"<style[^>]*>(.*?)</style>", text, re.S | re.I)]
    keep += [m.span(1) for m in re.finditer(r'\s(?:style|fill|stroke|color|stop-color)="([^"]*)"', text, re.I)]
    out = [c if c == "\n" else " " for c in text]
    for a, b in keep:
        out[a:b] = text[a:b]
    return "".join(out)


def check(path):
    text = css_regions(path, path.read_text())
    rel = path.relative_to(REPO) if path.is_relative_to(REPO) else path
    line = lambda pos: text.count("\n", 0, pos) + 1
    for m in HEX.finditer(text):
        before = text[max(0, text.rfind(";", 0, m.start()), text.rfind("{", 0, m.start())) + 1:m.start()]
        if CUSTOM_PROP.match(before):
            if m.group(0).lower() in TOKEN_HEX:
                continue
            yield f"{rel}:{line(m.start())}: {m.group(0)} is not a value from tokens/variables.css"
        else:
            yield f"{rel}:{line(m.start())}: raw colour {m.group(0)}, use a token via var()"
    for m in YELLOW_FILL.finditer(text):
        selector = text[max(text.rfind("}", 0, m.start()), 0):m.start()]
        if not YELLOW_FILL_OK.search(selector):
            yield f"{rel}:{line(m.start())}: fill with var(--yellow), use var(--primary) (and --on-primary for its text)"
    for m in FONT.finditer(text):
        value = " ".join(m.group(1).split())
        if not FONT_OK.match(value):
            yield f"{rel}:{line(m.start())}: font-family {value!r}, use var(--font-heading|sans|mono|control)"


def css_block(text, selector):
    """Custom properties of the first block with this selector: {name: value}."""
    start = text.index(selector)
    body = text[text.index("{", start) + 1:text.index("}", start)]
    body = re.sub(r"/\*.*?\*/", "", body, flags=re.S)
    return {m.group(1): m.group(2).strip().lower() for m in re.finditer(r"--([\w-]+)\s*:\s*([^;]+);", body)}


def check_shared_palette():
    """palette.json (apps, QML) and variables.css (web) must not drift apart."""
    import json
    palette = json.loads((KANTE / "tokens/palette.json").read_text())
    css = (KANTE / "tokens/variables.css").read_text()
    dark, light = css_block(css, ":root {"), css_block(css, ':root[data-theme="light"]')
    gold = css_block(css, ':root[data-kante="gold"]')
    expected = [(":root", dark, "accent", palette["accent"])]
    for group in ("backgrounds", "foregrounds"):
        expected += [(":root", dark, k, v) for k, v in palette[group].items()]
    expected += [(":root", dark, k, v["bright"]) for k, v in palette["semantic"].items()]
    expected += [(":root", dark, "cyan-n", palette["semantic"]["cyan"]["neutral"])]
    expected += [(":root", dark, k, v) for k, v in palette.get("extra", {}).items()]
    lt = palette["light"]
    expected += [("light", light, "accent", lt["accent"])]
    for group in ("backgrounds", "foregrounds", "semantic"):
        expected += [("light", light, k, v) for k, v in lt[group].items()]
    expected += [("light", light, k, v) for k, v in lt.get("extra", {}).items()]
    gd = palette["gold"]
    expected += [("gold", gold, "accent", gd["accent"])]
    for group in ("backgrounds", "foregrounds", "semantic", "extra"):
        expected += [("gold", gold, k, v) for k, v in gd[group].items()]
    for block, props, name, value in expected:
        if props.get(name) != value.lower():
            yield f"tokens/palette.json {name} = {value} but tokens/variables.css ({block}) has {props.get(name)}"


# fonts.css declares the font families themselves: it is the one place that names them
files = sorted(f for f in KANTE.glob("css/*.css") if f.name != "fonts.css") + sorted(KANTE.glob("templates/*.html")) + sorted(KANTE.glob("docs/**/index.html")) + [Path(a).resolve() for a in sys.argv[1:]]
problems = [p for f in files if f.exists() for p in check(f)] + list(check_shared_palette())
print("\n".join(problems) or f"token check ok ({len(files)} files)")
sys.exit(1 if problems else 0)
