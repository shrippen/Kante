#!/usr/bin/env bash
# Builds the Knust plugin zip from the committed files in kimai/knust:
#   dist/KnustBundle-<version>.zip  with the folder KnustBundle/ (Kimai expects var/plugins/KnustBundle/)
# Version from kimai/knust/composer.json. Without bin/, demo/, docs/ and the dot files; aborts if any
# demo code or data would land in the zip. build.sh and the release workflow run it.
# Usage: tools/knust-zip.sh [<git ref>]   (default HEAD)
set -euo pipefail
cd "$(dirname "$0")/.."
REF="${1:-HEAD}"
VERSION=$(python3 -c 'import json;print(json.load(open("kimai/knust/composer.json"))["version"])')
ZIP="dist/KnustBundle-$VERSION.zip"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p dist "$tmp/KnustBundle"
git archive "$REF:kimai/knust" | tar -x -C "$tmp/KnustBundle"
rm -rf "$tmp/KnustBundle"/{bin,demo,docs} "$tmp/KnustBundle"/.git*

# No demo in a release
if find "$tmp/KnustBundle" -ipath '*demo*' | grep -q . || grep -rIli 'demo' "$tmp/KnustBundle" --include='*.php' --include='*.yaml' --include='*.twig' | grep -q .; then
    echo "knust-zip: demo code or data in the package:" >&2
    find "$tmp/KnustBundle" -ipath '*demo*' >&2
    grep -rIli 'demo' "$tmp/KnustBundle" --include='*.php' --include='*.yaml' --include='*.twig' >&2 || true
    exit 1
fi

rm -f "$ZIP"
(cd "$tmp" && find KnustBundle -type f | LC_ALL=C sort | TZ=UTC zip -q -X "$OLDPWD/$ZIP" -@)
echo "built $ZIP ($(unzip -l "$ZIP" | tail -1 | awk '{print $2}') files)"
