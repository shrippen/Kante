#!/usr/bin/env bash
# Loads the Kante QML module and runs its tests (qml/tests) offscreen.
# Needs qmltestrunner (qt6-declarative) and Kirigami. Skips with a note if missing.
set -euo pipefail
cd "$(dirname "$0")/.."
RUNNER=""
for c in /usr/lib/qt6/bin/qmltestrunner qmltestrunner-qt6 qmltestrunner; do
    if command -v "$c" >/dev/null 2>&1; then RUNNER=$(command -v "$c"); break; fi
done
if [ -z "$RUNNER" ]; then
    echo "check-qml: qmltestrunner not found, skipped"
    exit 0
fi
QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-offscreen}" "$RUNNER" -import qml -input qml/tests 2>&1 \
    | grep -E "^(FAIL|PASS|Totals|QWARN|QDEBUG)|qml:|Error" | grep -vE "^PASS" || true
QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-offscreen}" "$RUNNER" -import qml -input qml/tests >/dev/null 2>&1
