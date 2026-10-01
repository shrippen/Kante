#!/usr/bin/env bash
# Lists the Kimai plugins next to this repo (../*/Resources/views/_kit) and whether their vendored kit
# equals kimai/kit (kimai/kit/bin/sync.sh --check). Changes nothing; update one with
#   kimai/kit/bin/sync.sh <plugin>
# Usage: tools/check-kit.sh   Exit 1 if a plugin is not on the current kit.
set -uo pipefail
cd "$(dirname "$0")/.."
kit="$(tr -d '[:space:]' < kimai/kit/VERSION)"
fail=0
for dir in ../*/; do
    [ -d "$dir/Resources/views/_kit" ] || continue
    have="$(tr -d '[:space:]' < "$dir/Resources/views/_kit/VERSION" 2>/dev/null || echo '?')"
    if kimai/kit/bin/sync.sh "$dir" --check >/dev/null 2>&1; then
        echo "ok   ${dir%/} (kit $have)"
    else
        echo "OLD  ${dir%/} (kit $have, current $kit)"
        fail=1
    fi
done
exit "$fail"
