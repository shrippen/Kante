#!/bin/sh
# Test for tools/knust-zip.sh: the plugin zip carries no rule files for agents.
# Usage: tools/knust-zip.test.sh   Exit 1 on a failure.
set -u
cd "$(dirname "$0")/.."
RULE_FILES='CLAUDE.md agent.md RULES.md RELEASE.md REVIEW.md'
fail=0

tools/knust-zip.sh > /dev/null || { echo "FAIL  knust-zip.sh did not build"; exit 1; }
zip="$(ls -t dist/KnustBundle-*.zip | head -1)"

for name in $RULE_FILES; do
    if unzip -Z1 "$zip" | grep -q "^KnustBundle/$name\$"; then
        echo "FAIL  $name is in $zip"
        fail=1
        continue
    fi

    echo "ok    no $name in the zip"
done

exit $fail
