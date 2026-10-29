#!/bin/sh
# Tests for tools/release-notes.sh. Usage: tools/release-notes.test.sh   Exit 1 on a failure.
set -u
cd "$(dirname "$0")"
script="$PWD/release-notes.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fail=0

ok()  { echo "ok    $1"; }
bad() { echo "FAIL  $1"; fail=1; }

# expect NAME EXPECTED_EXIT [ARGS...]: runs the script, stdout to $tmp/out, stderr to $tmp/err
expect() {
    name="$1" want="$2"; shift 2
    sh "$script" "$@" > "$tmp/out" 2> "$tmp/err"
    got=$?
    if [ "$got" = "$want" ]; then ok "$name"; else bad "$name (exit $got, wanted $want: $(cat "$tmp/err"))"; fi
}

cat > "$tmp/CHANGELOG.md" <<'EOF'
# Changelog

## [Unreleased]

- Not released yet.

## [1.30.0] — 2026-10-29

Thirty.

## [1.3.1] — 2026-10-20

Patch.

## [1.3] — 2026-10-01

### English

Lead three.

#### New
- A point.

### Deutsch

Lead drei.

## [0.10.0] — 2026-09-02

Ten.

## [0.1] — 2026-09-01

First, the last section of the file.
EOF

# Extraction
expect "1.3: own section only" 0 1.3 "$tmp/CHANGELOG.md"
grep -q "Lead three" "$tmp/out" && grep -q "Lead drei" "$tmp/out" && ! grep -qE "Thirty|Patch|Ten" "$tmp/out" \
    && ok "1.3: ### and #### stay inside, 1.30.0 and 1.3.1 are not taken" || bad "1.3: wrong text: $(cat "$tmp/out")"
[ "$(head -n 1 "$tmp/out")" = "### English" ] && [ "$(tail -n 1 "$tmp/out")" = "Lead drei." ] \
    && ok "1.3: no blank lines at start and end" || bad "1.3: blank lines kept"
expect "0.1: last section of the file" 0 0.1 "$tmp/CHANGELOG.md"
grep -q "First" "$tmp/out" && ! grep -q "Ten" "$tmp/out" && ok "0.1: does not take 0.10.0" || bad "0.1: $(cat "$tmp/out")"
expect "1.30.0 next to [Unreleased]" 0 1.30.0 "$tmp/CHANGELOG.md"
grep -qx "Thirty." "$tmp/out" || bad "1.30.0: $(cat "$tmp/out")"
expect "missing version fails" 1 2.0.0 "$tmp/CHANGELOG.md"
grep -q "no notes for 2.0.0" "$tmp/err" || bad "missing version: message $(cat "$tmp/err")"
expect "missing file fails" 1 1.3 "$tmp/none.md"

printf '## [2.0.0] — 2026-10-29\n\n\n## [1.0.0] — 2026-10-01\n\nOne.\n' > "$tmp/empty.md"
expect "empty section fails" 1 2.0.0 "$tmp/empty.md"

# Check
expect "check: good file" 0 --check "$tmp/CHANGELOG.md"
grep -q "5 releases ok" "$tmp/out" || bad "check: count $(cat "$tmp/out")"
expect "check: empty section" 1 --check "$tmp/empty.md"
printf '# Changelog\n\n## Upstream history\n\nOld.\n' > "$tmp/free.md"
expect "check: free heading, no release yet" 0 --check "$tmp/free.md"

for heading in "## 1.2.0" "## v1.2.0" "## [1.2.0](https://x)" "## [1.2.0] - 2026-10-01" "## [1.2.0]" "## 1.2.0 (2026-10-01)"; do
    printf '%s\n\nText.\n' "$heading" > "$tmp/h.md"
    expect "check: \"$heading\" is refused" 1 --check "$tmp/h.md"
done
printf '## [1.0.0] — 2026-10-01\n\nA.\n\n## [Unreleased]\n\nB.\n' > "$tmp/u.md"
expect "check: [Unreleased] below a release" 1 --check "$tmp/u.md"
printf '## [1.0.0] — 2026-10-01\n\nA.\n\n## [1.0.0] — 2026-09-01\n\nB.\n' > "$tmp/d.md"
expect "check: version twice" 1 --check "$tmp/d.md"

exit "$fail"
