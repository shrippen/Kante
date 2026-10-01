#!/usr/bin/env bash
# Palette check, like Kante's check-tokens.py:
#   1. Resources/public/css/knust.css has no raw hex colours (colours come from knust-palette.css)
#   2. every var(--shr-*) that knust.css reads is defined in knust-palette.css or knust.css
#   3. the vendored knust-palette.css equals Kante's build in this repo (../../docs/v1/knust-palette.css;
#      ./build.sh in the repo root copies it)
# Usage: kimai/knust/bin/check-palette.sh   Exit 1 on any finding (build.sh runs it).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CSS="$ROOT/Resources/public/css"
fail=0

# 1. no raw hex (comments stripped)
hex=$(sed 's#/\*.*\*/##g' "$CSS/knust.css" | grep -nE '#[0-9a-fA-F]{3,8}\b' || true)
if [ -n "$hex" ]; then
    echo "FAIL raw hex colours in knust.css (use a --shr-* token):" >&2
    echo "$hex" >&2
    fail=1
else
    echo "ok   knust.css without raw hex colours"
fi

# 2. every --shr-* read is defined
used=$(grep -oE 'var\(--shr-[a-z0-9-]+' "$CSS/knust.css" | sed 's/var(//' | sort -u)
defined=$(grep -hoE -- '--shr-[a-z0-9-]+\s*:' "$CSS/knust-palette.css" "$CSS/knust.css" | tr -d ' :' | sort -u)
missing=$(comm -23 <(echo "$used") <(echo "$defined"))
if [ -n "$missing" ]; then
    echo "FAIL --shr-* read but not defined:" $missing >&2
    fail=1
else
    echo "ok   every --shr-* in knust.css is defined"
fi

# 3. vendored copy matches Kante (the build in this repo, docs/v1/knust-palette.css)
src="$ROOT/../../docs/v1/knust-palette.css"
if cmp -s "$src" "$CSS/knust-palette.css"; then
    echo "ok   knust-palette.css matches Kante (docs/v1/knust-palette.css)"
else
    echo "FAIL knust-palette.css differs from Kante's build; run ./build.sh in the repo root" >&2
    diff "$CSS/knust-palette.css" "$src" | head -20 >&2 || true
    fail=1
fi
exit "$fail"
