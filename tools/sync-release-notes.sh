#!/usr/bin/env bash
# Copies tools/release-notes.sh into projects as scripts/release-notes.sh, unchanged.
#   tools/sync-release-notes.sh <project>...          copy
#   tools/sync-release-notes.sh <project>... --check  exit 1 if a copy differs (changes nothing)
#   tools/sync-release-notes.sh --all [--check]       every project next to this repo (../*/) with a
#                                                     CHANGELOG.md and a scripts/release-notes.sh
# A project calls its copy in the release workflow (`scripts/release-notes.sh "$VERSION" > notes.md`)
# and checks its CHANGELOG.md in CI on every push (`scripts/release-notes.sh --check`).
set -uo pipefail
cd "$(dirname "$0")/.."
src="$PWD/tools/release-notes.sh"

check=0
all=0
projects=()
for arg in "$@"; do
    case "$arg" in
        --check) check=1 ;;
        --all) all=1 ;;
        *) projects+=("$arg") ;;
    esac
done
if [ "$all" = 1 ]; then
    for dir in ../*/ ../*/*/; do
        [ -f "$dir/CHANGELOG.md" ] && [ -f "$dir/scripts/release-notes.sh" ] && projects+=("${dir%/}")
    done
fi
[ "${#projects[@]}" -gt 0 ] || { echo "usage: tools/sync-release-notes.sh <project>... [--check] | --all [--check]" >&2; exit 2; }

fail=0
for dir in "${projects[@]}"; do
    dest="$dir/scripts/release-notes.sh"
    if cmp -s "$src" "$dest"; then
        echo "ok   $dir"
        continue
    fi
    if [ "$check" = 1 ]; then
        echo "OLD  $dir (scripts/release-notes.sh differs from Kante's tools/release-notes.sh)"
        fail=1
        continue
    fi
    mkdir -p "$dir/scripts"
    cp "$src" "$dest"
    chmod +x "$dest"
    echo "copied $dir"
done
exit "$fail"
