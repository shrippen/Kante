#!/usr/bin/env python3
"""Generates tokens/variables.css (the web's custom properties) from tokens/palette.json.

  tokens/variables.src.css   hand-written: roles, tints, sizes, motion, type; every colour
                             value is a placeholder {{theme.name}}
  tokens/variables.css       generated: the placeholders replaced by the palette's values

Themes: dark, light (Leinen), kanteLight, kanteLightDark (Kante Light under
prefers-color-scheme: dark), gold. The name is the custom property's name without "--".

Edit the colours in tokens/palette.json, the rest in tokens/variables.src.css; never
tokens/variables.css. Usage: python3 tools/build-variables.py   (build.sh runs it)
"""
import json
import re
import sys
from pathlib import Path

KANTE = Path(__file__).resolve().parent.parent
SRC = KANTE / "tokens/variables.src.css"
OUT = KANTE / "tokens/variables.css"
PLACEHOLDER = re.compile(r"\{\{(\w+)\.([\w-]+)\}\}")
GROUPS = ("backgrounds", "foregrounds", "semantic", "extra")


def flat(theme):
    """Custom property name -> hex of a theme block of palette.json (light, gold, ...)."""
    colours = {"accent": theme["accent"]}
    for group in GROUPS:
        colours.update(theme[group])
    return colours


def dark(palette):
    """The default theme: bright and neutral (-n) semantic colours, plus the extras."""
    colours = {"accent": palette["accent"]}
    colours.update(palette["backgrounds"])
    colours.update(palette["foregrounds"])
    colours.update(palette["extra"])
    for name, shades in palette["semantic"].items():
        colours[name] = shades["bright"]
        colours[name + "-n"] = shades["neutral"]
    colours["blue-hover"] = palette["semantic"]["blue"]["hover"]
    return colours


def themes(palette):
    kante_light = palette["kanteLight"]
    return {
        "dark": dark(palette),
        "light": flat(palette["light"]),
        "kanteLight": flat(kante_light["light"]),
        "kanteLightDark": flat(kante_light["dark"]),
        "gold": flat(palette["gold"]),
    }


def main():
    palette = json.loads((KANTE / "tokens/palette.json").read_text())
    values = themes(palette)
    missing = []

    def value(match):
        theme, name = match.groups()
        found = values.get(theme, {}).get(name)
        if found is None:
            missing.append(match.group(0))
            return match.group(0)
        return found

    OUT.write_text(PLACEHOLDER.sub(value, SRC.read_text()))
    if missing:
        sys.exit("tokens/variables.src.css: not in tokens/palette.json: " + ", ".join(missing))
    print(f"built {OUT.relative_to(KANTE)}")


main()
