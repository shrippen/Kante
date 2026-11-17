import QtQuick
import QtTest
import Kante

/** KanteSteps.minStepWidth: the least width of a named step. */
TestCase {
    name: "KanteStepsMinWidth"

    readonly property real roomWidth: 300

    Component { id: stepsComponent; KanteSteps { model: ["A", "B", "C", "D"]; current: 1 } }

    // 4 steps of 110 need over 440, of 20 (their labels are short) under 300.
    function test_defaultIsCompactInRoom() {
        const s = createTemporaryObject(stepsComponent, this)
        s.width = roomWidth
        verify(s.compact)
    }

    function test_smallerMinWidthFitsInRoom() {
        const s = createTemporaryObject(stepsComponent, this, { minStepWidth: KanteStyle.unit(20) })
        s.width = roomWidth
        verify(!s.compact)
    }
}
