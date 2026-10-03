#!/usr/bin/env bash
# Builds everything in Kante: the design system, Knust and the Kimai plugin kit.
#   1. Kante for the web: docs/v1/shrippen.css, shrippen.js, kante-map.js and map/, fonts.css and fonts/
#      -> shrippen.github.io copies docs/v1/ (its build.sh), served at https://shrippen.github.io/v1/
#   2. Kante for apps: qml/Kante/KantePalette.qml, tokens/palette.qml and the bundled fonts,
#      generated from tokens/palette.json (tools/build-qml.py)
#   3. Knust palette: docs/v1/knust-palette.css (--shr-* for the Kimai theme), copied unchanged
#      into kimai/knust/Resources/public/css/ (tools/build-knust.py)
#   4. Token check: no raw colours or fonts outside tokens/, palette.json matches variables.css
#      (tools/check-tokens.py); Knust's palette check (kimai/knust/bin/check-palette.sh)
#   5. QML module test: qml/tests, if qmltestrunner is installed (tools/check-qml.sh)
#   6. Kimai plugin kit: assets.html.twig from kit.css/kit.js, self test (kimai/kit/bin/lint.sh)
#   7. Knust plugin zip: dist/KnustBundle-<version>.zip from the committed files (tools/knust-zip.sh)
#   8. Union style (spike): union/ styles and KDE colour schemes from palette.json (tools/build-union.py),
#      checked against Union's property list (tools/check-union.py)
#   9. Claude Design upload: ds-bundle/ (.design-sync/make-bundle.py, gitignored)
#  10. Specimen: tools/specimen.html in dark, Leinen, Kante Light and Gold -> dist/specimen/
#      (tools/shoot-specimen.py; skipped when $KANTE_PY has no Playwright)
set -euo pipefail
cd "$(dirname "$0")"
OUT=docs/v1
mkdir -p "$OUT"
{
  echo "/* Kante v1 — https://github.com/shrippen/shrippen.github.io */"
  cat tokens/variables.css css/base.css css/components.css
} > "$OUT/shrippen.css"
cp js/shrippen.js "$OUT/shrippen.js"
# Vector maps: kante-map.js and the map libraries it loads on first use (map/)
cp js/kante-map.js "$OUT/kante-map.js"
mkdir -p "$OUT/map"
cp js/map/* "$OUT/map/"
# Offline fonts: fonts.css plus the font files next to it (opt-in, apps that must work without Google Fonts)
mkdir -p "$OUT/fonts"
cp fonts/*.ttf fonts/*.woff2 fonts/OFL.txt "$OUT/fonts/"
cp css/fonts.css "$OUT/fonts.css"
echo "built $OUT/shrippen.css ($(wc -c < "$OUT/shrippen.css") bytes), shrippen.js"
python3 tools/build-qml.py
python3 tools/build-knust.py
cp "$OUT/knust-palette.css" kimai/knust/Resources/public/css/knust-palette.css
python3 tools/check-tokens.py
kimai/knust/bin/check-palette.sh
tools/check-qml.sh
kimai/kit/bin/build-assets.sh >/dev/null
kimai/kit/bin/lint.sh
tools/knust-zip.sh
python3 tools/build-union.py
python3 tools/check-union.py
python3 .design-sync/make-bundle.py
KANTE_PY="${KANTE_PY:-$(realpath -m ../shrippen.github.io/demo/tools/.venv/bin/python)}"
if "$KANTE_PY" -c "import playwright" 2>/dev/null; then
  "$KANTE_PY" tools/shoot-specimen.py
else
  echo "specimen skipped (no Playwright in \$KANTE_PY)"
fi
