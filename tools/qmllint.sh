#!/usr/bin/env bash
# qmllint over the Kante QML module (Qt 6.12 and later), as the CI runs it. Exit code 1 on any
# finding. Local: tools/qmllint.sh; JSON with every finding: tools/qmllint.sh --json -
#
# Off, on purpose:
#   unqualified, missing-property   Kante reads its style through context properties by design.
#   block-scope-var-declaration     Qt 6.12 reports every `var` inside a block (hundreds). The
#                                   code runs as written; a blind switch to let/const breaks every
#                                   place that reads the variable after its block. Switch file by
#                                   file when you work on it and test it (agent.md).
# Singletons (`pragma Singleton`) run in a second pass without the import check: Qt 6.12 reports
# each of them as "not declared as singleton in qmldir", even in a minimal correct module
# (qmldir `singleton A 1.0 A.qml`). All other files keep the import check.
#
# Note: the plain text output of Qt 6.12's qmllint leaves out some findings that the exit code
# counts; --json shows all of them.
set -uo pipefail
cd "$(dirname "$0")/.."
QMLLINT=/usr/lib/qt6/bin/qmllint
command -v "$QMLLINT" >/dev/null || QMLLINT=$(command -v qmllint6 || command -v qmllint)
Q=("$QMLLINT" --unqualified disable --missing-property disable --block-scope-var-declaration disable
   --max-warnings 0 -I qml "$@")
files=(qml/Kante/*.qml qml/KantePlasma/*.qml)
mapfile -t singletons < <(grep -l '^pragma Singleton' "${files[@]}")
mapfile -t others < <(grep -L '^pragma Singleton' "${files[@]}")
rc=0
"${Q[@]}" "${others[@]}" || rc=1
"${Q[@]}" --import disable "${singletons[@]}" || rc=1
[ $rc = 0 ] && echo "qmllint: no findings"
exit $rc
