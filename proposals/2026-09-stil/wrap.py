#!/usr/bin/env python3
"""Wrap the artifact sources (body-only HTML) into standalone pages.

The pages were published as a claude.ai artifact, which adds the document
skeleton itself. For the repo copy this script adds it back.
Usage: python3 wrap.py SRC_DIR  (writes index.html, bauteile.html next to it)
"""
import pathlib, sys

HEAD = ('<!doctype html>\n<html lang="de">\n<head>\n<meta charset="utf-8">\n'
        '<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">\n')
here = pathlib.Path(__file__).parent
src = pathlib.Path(sys.argv[1])
for name in ("index.html", "bauteile.html"):
    f = src / name
    if not f.exists():
        continue
    body = f.read_text(encoding="utf-8")
    # <title>, <link>, <style> may sit in the body; browsers move them to the head.
    (here / name).write_text(HEAD + "</head>\n<body>\n" + body + "\n</body>\n</html>\n", encoding="utf-8")
