#!/usr/bin/env bash
# Runs the QML tests against a real Kirigami 6 build (no stub).
# Usage: KF6_PREFIX=/path/to/env check-qml-real.sh
#   $KF6_PREFIX has Qt 6 (lib/qt6/bin/qmltestrunner) and Kirigami under kf/lib/x86_64-linux-gnu/qml.
# Building it without Plasma: micromamba create -n kb -c conda-forge qt6-main cmake ninja gxx_linux-64 git,
# then build extra-cmake-modules and kirigami (tag v6.30.0) from invent.kde.org into $KF6_PREFIX/kf.
set -euo pipefail
cd "$(dirname "$0")/.."
P="${KF6_PREFIX:?set KF6_PREFIX}"
export QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/xdg}"
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"
export LD_LIBRARY_PATH="$P/kf/lib/x86_64-linux-gnu:$P/lib"
"$P/lib/qt6/bin/qmltestrunner" -import qml -import "$P/kf/lib/x86_64-linux-gnu/qml" -input qml/tests
