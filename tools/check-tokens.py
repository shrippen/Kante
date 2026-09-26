#!/usr/bin/env python3
"""Checks that the design system's sources use tokens instead of raw values.

  - No raw hex colours outside tokens/variables.css. The only exception is a custom
    property that re-sets a token locally (e.g. `.stage{--bg1:#3c3836}`), and its value
    must be one of the hex values defined in tokens/variables.css.
  - font-family always comes from a token: var(--font-heading|--font-sans|--font-mono) or inherit.

Scans css/*.css, templates/*.html and docs/index.html (in HTML only <style>, style="…"
and fill/stroke/color attributes). Exits 1 on any finding.
Usage: python3 tools/check-tokens.py   (build.sh runs it)
"""
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
HEX = re.compile(r"#(?:[0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{3,4})\b")
TOKEN_HEX = {h.lower() for h in HEX.findall((REPO / "tokens/variables.css").read_text())}
FONT = re.compile(r"font-family\s*:\s*([^;}\"]+)", re.I)
FONT_OK = re.compile(r"^(var\(--font-(heading|sans|mono)\)|inherit)$")
CUSTOM_PROP = re.compile(r"\s*--[\w-]+\s*:")


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
    rel = path.relative_to(REPO)
    line = lambda pos: text.count("\n", 0, pos) + 1
    for m in HEX.finditer(text):
        before = text[max(0, text.rfind(";", 0, m.start()), text.rfind("{", 0, m.start())) + 1:m.start()]
        if CUSTOM_PROP.match(before):
            if m.group(0).lower() in TOKEN_HEX:
                continue
            yield f"{rel}:{line(m.start())}: {m.group(0)} is not a value from tokens/variables.css"
        else:
            yield f"{rel}:{line(m.start())}: raw colour {m.group(0)}, use a token via var()"
    for m in FONT.finditer(text):
        value = " ".join(m.group(1).split())
        if not FONT_OK.match(value):
            yield f"{rel}:{line(m.start())}: font-family {value!r}, use var(--font-heading|sans|mono)"


files = sorted(REPO.glob("css/*.css")) + sorted(REPO.glob("templates/*.html")) + [REPO / "docs/index.html"]
problems = [p for f in files if f.exists() for p in check(f)]
print("\n".join(problems) or f"token check ok ({len(files)} files)")
sys.exit(1 if problems else 0)
