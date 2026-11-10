#!/bin/sh
# Test for tools/knust-zip.sh: the plugin zip carries no rule files for agents.
# Usage: tools/knust-zip.test.sh   Exit 1 on a failure.
set -u
cd "$(dirname "$0")/.."
RULE_FILES='CLAUDE.md agent.md RULES.md RELEASE.md REVIEW.md'
fail=0

# A newer zip of another version in dist/ (mtime an hour ahead, so it stays the newest
# after the build) must not be the one checked
decoy="dist/KnustBundle-0.0.0-decoy.zip"
trap 'rm -rf "$decoy" "$decoy.d"' EXIT
mkdir -p "$decoy.d/KnustBundle"
touch "$decoy.d/KnustBundle/CLAUDE.md"
(cd "$decoy.d" && zip -q -r "../$(basename "$decoy")" KnustBundle)
touch -d '+1 hour' "$decoy"

# knust-zip.sh names what it built: "built dist/KnustBundle-1.5.0.zip (123 files)"
built="$(tools/knust-zip.sh)" || { echo "FAIL  knust-zip.sh did not build"; exit 1; }
zip="$(echo "$built" | sed -n 's/^built \(.*\) (.*/\1/p')"
[ -f "$zip" ] || { echo "FAIL  no zip path in: $built"; exit 1; }

for name in $RULE_FILES; do
    if unzip -Z1 "$zip" | grep -q "^KnustBundle/$name\$"; then
        echo "FAIL  $name is in $zip"
        fail=1
        continue
    fi

    echo "ok    no $name in the zip"
done

exit $fail
