#!/usr/bin/env python3
"""Checks the Union side of Kante (kante/union/) without needing Union installed.

  - Every CSS property in template/controls.css is one Union's CSS input knows
    (union-properties.txt, taken from Union's property reference).
  - Pseudo-classes are the states Union supports; combinators are only descendant and child.
  - No raw colours or fonts in the template (colours come from the generated variables.css).
  - Every var(--k-*) is defined in variables.css.
  - The generated styles and colour schemes are up to date with tokens/palette.json.
Exits 1 on any finding. Usage: python3 kante/tools/check-union.py   (build.sh runs it)
"""
import importlib.util
import re
import sys
from pathlib import Path

KANTE = Path(__file__).resolve().parent.parent
UNION = KANTE / "union"
STATES = {"hovered", "active-focus", "visual-focus", "pressed", "checked", "disabled", "highlighted"}

_spec = importlib.util.spec_from_file_location("build_union", Path(__file__).with_name("build-union.py"))
bu = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(bu)

problems = []
text = (UNION / "template/controls.css").read_text()
text = re.sub(r"/\*.*?\*/", lambda m: re.sub(r"[^\n]", " ", m.group(0)), text, flags=re.S)
line = lambda pos: text.count("\n", 0, pos) + 1
known = {l.strip() for l in (UNION / "union-properties.txt").read_text().splitlines() if l.strip() and not l.startswith("#")}
variables = bu.variables_css(bu.STYLES["kante"])
defined = set(re.findall(r"(--k-[\w-]+)\s*:", variables))

for m in re.finditer(r"(?:^|[;{])\s*([a-z][a-z-]*)\s*:(?!\S)", text, re.M):
    if m.group(1) not in known:
        problems.append(f"controls.css:{line(m.start())}: property {m.group(1)} is not in union-properties.txt")
for m in re.finditer(r":([a-z-]+)", re.sub(r"\{[^}]*\}", "{}", text)):
    if m.group(1) not in STATES:
        problems.append(f"controls.css: unsupported pseudo-class :{m.group(1)}")
for m in re.finditer(r"#[0-9a-fA-F]{3,8}\b|\brgba?\(", text):
    problems.append(f"controls.css:{line(m.start())}: raw colour, use a --k-* role")
for m in re.finditer(r"font-family", text):
    problems.append(f"controls.css:{line(m.start())}: font-family, fonts stay with the platform")
for m in re.finditer(r"var\((--k-[\w-]+)\)", text):
    if m.group(1) not in defined:
        problems.append(f"controls.css:{line(m.start())}: {m.group(1)} is not defined in variables.css")

for key, style in bu.STYLES.items():
    css = UNION / "styles" / key / "contents/css"
    expect = {css / "variables.css": bu.variables_css(style), css / "style.css": bu.style_css(),
              css / "controls.css": (UNION / "template/controls.css").read_text(),
              UNION / "colors" / ("%s.colors" % style["scheme"]): bu.colors_scheme(style)}
    for path, want in expect.items():
        if not path.exists() or path.read_text() != want:
            problems.append(f"{path.relative_to(KANTE.parent)} is out of date, run ./build.sh")

for p in problems:
    print(p)
if problems:
    sys.exit(1)
print("union check ok: %d properties known, styles and colour schemes up to date" % len(known))
